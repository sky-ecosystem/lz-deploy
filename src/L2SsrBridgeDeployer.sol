// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { SSRAuthOracle }     from "xchain-ssr-oracle/SSRAuthOracle.sol";
import { LZComposeReceiver } from "xchain-helpers/receivers/LZComposeReceiver.sol";

import { LZInit, UlnConfig, EndpointLike } from "lz-init-lib/LZInit.sol";

/// @notice Deploys the remote half of an SSR oracle bridge: the oracle and the LZ receiver that feeds
///         it from mainnet.
/// @dev    Two steps, because the L1 forwarder takes the receiver's address as a constructor immutable
///         and the receiver takes the forwarder's: the constructor computes where the receiver will
///         land, the forwarder is built against that, and `deployReceiver` then creates it. The
///         README gives the cross-chain sequence.
contract L2SsrBridgeDeployer {

    uint32 internal constant ETH_EID = 30101;

    address public immutable deployer;

    SSRAuthOracle public immutable oracle;

    /// @notice The address `deployReceiver` will use. Give it to `L1SsrBridgeDeployer` first.
    address public immutable predictedReceiver;

    LZComposeReceiver public receiver;

    modifier onlyDeployer() {
        require(msg.sender == deployer, "L2SsrBridgeDeployer/not-deployer");
        _;
    }

    /// @param maxSSR      Cap on the SSR the oracle accepts; `0` for no cap.
    /// @param oracleAdmin Holder of the oracle's `DEFAULT_ADMIN_ROLE`; `address(0)` leaves none, which
    ///                    freezes `maxSSR` and `DATA_PROVIDER_ROLE` for good.
    constructor(uint256 maxSSR, address oracleAdmin) {
        deployer = msg.sender;

        // Nonce 2: a contract's starts at 1 (EIP-161) and the constructor consumes it on the oracle.
        predictedReceiver = address(uint160(uint256(keccak256(
            abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(this), uint8(2))
        ))));

        oracle = new SSRAuthOracle();
        oracle.setMaxSSR(maxSSR);
        oracle.grantRole(oracle.DATA_PROVIDER_ROLE(), predictedReceiver);

        if (oracleAdmin != address(0)) {
            oracle.grantRole(oracle.DEFAULT_ADMIN_ROLE(), oracleAdmin);
        }
        oracle.renounceRole(oracle.DEFAULT_ADMIN_ROLE(), address(this));
    }

    /// @notice Deploy the LZ receiver, configure its receive side and hand it to governance. The oracle
    ///         already authorises the address it lands at.
    function deployReceiver(
        address          endpoint,
        address          forwarder,
        address          recvLib,
        UlnConfig memory recvUlnCfg,
        address          gov
    ) external onlyDeployer {
        require(address(receiver) == address(0), "L2SsrBridgeDeployer/receiver-already-deployed");

        receiver = new LZComposeReceiver({
            _destinationEndpoint: endpoint,
            _srcEid:              ETH_EID,
            _sourceAuthority:     bytes32(uint256(uint160(forwarder))),
            _target:              address(oracle),
            _delegate:            address(this),
            _owner:               address(this)
        });

        EndpointLike(endpoint).setReceiveLibrary({
            oapp:        address(receiver),
            eid:         ETH_EID,
            newLib:      recvLib,
            gracePeriod: 0
        });

        LZInit.setUlnConfig(address(receiver), ETH_EID, recvLib, recvUlnCfg);

        receiver.setDelegate(gov);
        receiver.transferOwnership(gov);
    }
}
