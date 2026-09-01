// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { ERC1967Proxy }            from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { SkyOFTAdapterMintBurn }   from "sky-oapp-oft/SkyOFTAdapterMintBurn.sol";
import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits } from "lz-init-lib/LZInit.sol";

interface OFTAdapterAdminLike {
    function setDelegate(address delegate) external;
    function transferOwnership(address newOwner) external;
    function setRateLimitAccountingType(RateLimitAccountingType rateLimitAccountingType) external;
    function setPauser(address pauser, bool canPause) external;
}

/// @notice Deploys a remote Sky OFT adapter and pre-configures it to the state a spell later
///         asserts via `LZInit.activateOft`.
/// @dev    One instance per token per chain: the token is an implementation immutable, and two
///         implementations in one deployer would push its initcode near the EIP-3860 limit.
///
///         Bring-up, all by the deploying EOA: constructor, `wireRemote` per remote, optional
///         `setAccountingType`/`setPausers`, then `handOff(l2GovernanceRelay)`. Nothing is
///         end-to-end testable until the spell wires the far side; `quoteSend` is the most that can
///         be checked live.
///
///         Wiring is `LZInit.wireOftPeer` itself, the code a spell runs on the other side of the
///         route, so both ends come from one implementation.
contract OFTDeployer {

    address public immutable deployer;
    address public immutable endpoint;
    address public immutable implementation;
    address public immutable oft;

    bool public wired;
    bool public handedOff;

    event Wired(uint32 indexed remoteEid);
    event HandedOff(address indexed gov);

    modifier onlyDeployer() {
        require(msg.sender == deployer, "OFTDeployer/not-deployer");
        _;
    }

    modifier notHandedOff() {
        require(!handedOff, "OFTDeployer/handed-off");
        _;
    }

    /// @param token     The underlying ERC20. It must be given mint/burn authority over the adapter
    ///                  separately; that is out of scope here.
    /// @param endpoint_ The LayerZero EndpointV2 on this chain.
    constructor(address token, address endpoint_) {
        deployer = msg.sender;
        endpoint = endpoint_;

        implementation = address(new SkyOFTAdapterMintBurn(token, endpoint_));

        // `initialize` makes this contract both owner and endpoint delegate, which is what lets the
        // calls below reach the OApp's setters and the endpoint's config setters.
        oft = address(new ERC1967Proxy(
            implementation,
            abi.encodeCall(SkyOFTAdapterMintBurn.initialize, (address(this)))
        ));
    }

    /// @notice Connect the adapter to one remote peer: peer, libraries, executor and ULN configs,
    ///         enforced options and rate limits.
    /// @dev    Fresh-wire only. Call for *every* remote the OFT serves at go-live, not just L1: a
    ///         spell wiring a new chain only relays `wireOftPeer` on the sides that already exist.
    ///
    ///         Leave `rateLimits` at zero unless the bridge is meant to go live without governance
    ///         activation — `activateOft` verifies the whole config and requires them to be zero.
    function wireRemote(
        uint32            remoteEid,
        OftConfig  memory cfg,
        RateLimits memory rateLimits
    ) external onlyDeployer notHandedOff {
        LZInit.wireOftPeer(oft, remoteEid, cfg, rateLimits);
        wired = true;
        emit Wired(remoteEid);
    }

    /// @notice Update rate limits for an already-wired remote.
    function setRateLimits(uint32 remoteEid, RateLimits memory rateLimits) external onlyDeployer notHandedOff {
        LZInit.updateRateLimits(oft, remoteEid, rateLimits);
    }

    /// @notice Set the rate limit accounting type. Defaults to `Net`; `activateOft` asserts the exact value.
    /// @dev    Set before wiring: switching later leaves accrued in-flight amounts on the old rule.
    function setAccountingType(RateLimitAccountingType accountingType) external onlyDeployer notHandedOff {
        OFTAdapterAdminLike(oft).setRateLimitAccountingType(accountingType);
    }

    /// @notice Grant or revoke the ability to pause the adapter.
    /// @dev    `setPauser` reverts on a no-op change.
    function setPausers(address[] calldata pausers, bool canPause) external onlyDeployer notHandedOff {
        for (uint256 i; i < pausers.length; ++i) {
            OFTAdapterAdminLike(oft).setPauser(pausers[i], canPause);
        }
    }

    /// @notice Hand the adapter to governance: the L2GovernanceRelay on an L2, MCD_PAUSE_PROXY on L1.
    /// @dev    Irreversible. `activateOft` asserts owner and delegate are the same address, so both
    ///         move together; the delegate must be set before ownership leaves this contract.
    function handOff(address gov) external onlyDeployer notHandedOff {
        require(gov != address(0), "OFTDeployer/gov-is-zero");
        require(wired,             "OFTDeployer/nothing-wired");

        handedOff = true;

        OFTAdapterAdminLike(oft).setDelegate(gov);
        OFTAdapterAdminLike(oft).transferOwnership(gov);

        emit HandedOff(gov);
    }
}
