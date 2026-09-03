// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { SSRAuthOracle }                   from "xchain-ssr-oracle/SSRAuthOracle.sol";
import { SSRBalancerRateProviderAdapter }  from "xchain-ssr-oracle/adapters/SSRBalancerRateProviderAdapter.sol";
import { SSRChainlinkRateProviderAdapter } from "xchain-ssr-oracle/adapters/SSRChainlinkRateProviderAdapter.sol";
import { LZComposeReceiver }               from "xchain-helpers/receivers/LZComposeReceiver.sol";

import { LZInit, UlnConfig, EndpointLike } from "lz-init-lib/LZInit.sol";

/// @notice Deploys the remote half of an SSR oracle bridge: the oracle, its rate-provider adapters,
///         and the LZ receiver that feeds it from mainnet.
/// @dev    Split into two steps to break the circular dependency with the L1 forwarder, which takes
///         the receiver as an immutable while the receiver takes the forwarder as its immutable
///         `sourceAuthority`:
///           1. `new SsrRemoteDeployer(endpoint)`      remote
///           2. read `predictedReceiver()`
///           3. deploy `SsrForwarderDeployer` with it  mainnet
///           4. `deployReceiver(forwarder, ...)`       remote - asserts the prediction held
///           5. `handOff(gov, oracleAdmin)`            remote
///
///         `xchain-ssr-oracle`'s own script breaks the same cycle by predicting an EOA's `CREATE`
///         address across two forks; predicting this contract's keeps the guard on-chain.
contract SsrRemoteDeployer {

    uint32 internal constant ETH_EID = 30101;

    // A contract's nonce starts at 1 (EIP-161) and the constructor consumes 1-3.
    uint256 internal constant RECEIVER_NONCE = 4;

    address public immutable deployer;
    address public immutable endpoint;

    SSRAuthOracle                   public immutable oracle;
    SSRBalancerRateProviderAdapter  public immutable balancerAdapter;
    SSRChainlinkRateProviderAdapter public immutable chainlinkAdapter;

    LZComposeReceiver public receiver;

    event ReceiverDeployed(address indexed receiver, address indexed forwarder);
    event HandedOff(address indexed gov, address indexed oracleAdmin);

    modifier onlyDeployer() {
        require(msg.sender == deployer, "SsrRemoteDeployer/not-deployer");
        _;
    }

    constructor(address endpoint_) {
        deployer = msg.sender;
        endpoint = endpoint_;

        oracle           = new SSRAuthOracle();
        balancerAdapter  = new SSRBalancerRateProviderAdapter(oracle);
        chainlinkAdapter = new SSRChainlinkRateProviderAdapter(oracle);
    }

    /// @notice The address `deployReceiver` will use. Give it to the L1 `SsrForwarderDeployer` first.
    function predictedReceiver() public view returns (address) {
        // RLP(address, nonce) for a single-byte nonce below 0x80.
        return address(uint160(uint256(keccak256(
            abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(this), uint8(RECEIVER_NONCE))
        ))));
    }

    /// @notice Cap the SSR the oracle accepts.
    /// @dev    Only while this contract still holds the oracle's admin role, i.e. before `handOff`.
    function setMaxSSR(uint256 maxSSR) external onlyDeployer {
        oracle.setMaxSSR(maxSSR);
    }

    /// @notice Deploy the LZ receiver, authorise it on the oracle and configure its receive side.
    /// @dev    DVN arrays in `recvUlnCfg` must be strictly ascending by address.
    function deployReceiver(
        address          forwarder,
        address          recvLib,
        UlnConfig memory recvUlnCfg
    ) external onlyDeployer {

        address predicted = predictedReceiver();

        receiver = new LZComposeReceiver({
            _destinationEndpoint: endpoint,
            _srcEid:             ETH_EID,
            _sourceAuthority:    bytes32(uint256(uint160(forwarder))),
            _target:             address(oracle),
            _delegate:           address(this),
            _owner:              address(this)
        });

        // The forwarder holds the receiver as an immutable, so a mismatch cannot be reconfigured away.
        require(address(receiver) == predicted, "SsrRemoteDeployer/receiver-address-mismatch");

        oracle.grantRole(oracle.DATA_PROVIDER_ROLE(), address(receiver));

        EndpointLike(endpoint).setReceiveLibrary({
            oapp:        address(receiver),
            eid:         ETH_EID,
            newLib:      recvLib,
            gracePeriod: 0
        });

        LZInit.setUlnConfig(address(receiver), ETH_EID, recvLib, recvUlnCfg);

        emit ReceiverDeployed(address(receiver), forwarder);
    }

    /// @notice Hand the receiver to governance and settle the oracle's admin role.
    /// @param gov         Governance on this chain (the `L2GovernanceRelay`): takes the receiver.
    /// @param oracleAdmin Holder of the oracle's `DEFAULT_ADMIN_ROLE`; `address(0)` leaves none.
    /// @dev    With no admin, `setMaxSSR` and `DATA_PROVIDER_ROLE` are frozen for good — changing the
    ///         data source then means a new oracle and new consumers. Same trade-off
    ///         `xchain-ssr-oracle`'s deploy script offers.
    function handOff(address gov, address oracleAdmin) external onlyDeployer {
        receiver.setDelegate(gov);
        receiver.transferOwnership(gov);

        if (oracleAdmin != address(0)) {
            oracle.grantRole(oracle.DEFAULT_ADMIN_ROLE(), oracleAdmin);
        }
        oracle.renounceRole(oracle.DEFAULT_ADMIN_ROLE(), address(this));

        emit HandedOff(gov, oracleAdmin);
    }
}
