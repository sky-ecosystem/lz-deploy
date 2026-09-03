// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { ERC1967Proxy }            from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { SkyOFTAdapter }           from "sky-oapp-oft/SkyOFTAdapter.sol";
import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits } from "lz-init-lib/LZInit.sol";

/// @notice One remote the adapter serves at go-live. Leave `rateLimits` at zero unless the bridge is
///         meant to go live without governance activation — `activateOft` verifies the whole config
///         and requires them to be zero.
struct RemoteWiring {
    uint32     eid;
    OftConfig  cfg;
    RateLimits rateLimits;
}

/// @notice As `L2OftDeployment`, plus the two things only a lockbox has: the accounting type for the
///         global (sentinel) bucket, and the bucket itself. `SkyOFTAdapter` enforces that cap on top
///         of the per-eid ones, so an unset one with non-zero per-eid limits blocks every transfer;
///         leave `globalLimits` at zero only when a spell sets it.
struct L1OftDeployment {
    address                 token;
    address                 endpoint;
    RateLimitAccountingType accountingType;
    RateLimitAccountingType aggregateAccountingType;
    RateLimits              globalLimits;
    address[]               pausers;
    RemoteWiring[]          remotes;
    address                 gov;
}

/// @notice Deploys a mainnet Sky OFT lockbox, pre-configures it to the state a spell later asserts
///         via `LZInit.activateOft`, and hands it to governance — all in the constructor.
/// @dev    One instance per token: the token is an implementation immutable, and two implementations
///         in one deployer would push its initcode near the EIP-3860 limit.
///
///         The satellite counterpart is `L2OFTDeployer`. A lockbox differs in three ways: it holds
///         the backing rather than minting, it enforces a global cap across all remotes on top of
///         the per-eid buckets, and it belongs to `MCD_PAUSE_PROXY` rather than a relay.
contract L1OFTDeployer {

    SkyOFTAdapter public immutable implementation;
    SkyOFTAdapter public immutable oft;

    /// @param d `token`                   the underlying ERC20, held as backing by the lockbox
    ///          `endpoint`                the LayerZero EndpointV2 on mainnet
    ///          `accountingType`          per-eid buckets; asserted verbatim by `activateOft`
    ///          `aggregateAccountingType` the global (sentinel) bucket's own, independent of it
    ///          `globalLimits`            the global cap; zero leaves it to a spell, and blocks
    ///                                       transfers until one sets it
    ///          `pausers`                 granted the ability to pause the adapter
    ///          `remotes`                 every remote the lockbox serves at go-live
    ///          `gov`                     `MCD_PAUSE_PROXY`; `activateOft` asserts owner and delegate
    ///                                       are the same address, so both move together
    constructor(L1OftDeployment memory d) {
        implementation = new SkyOFTAdapter(d.token, d.endpoint);

        // `initialize` makes this contract both owner and endpoint delegate, which is what lets the
        // calls below reach the OApp's setters and the endpoint's config setters.
        oft = SkyOFTAdapter(address(new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(SkyOFTAdapter.initialize, (address(this)))
        )));

        oft.setRateLimitAccountingType(d.accountingType);
        oft.setAggregateRateLimitAccountingType(d.aggregateAccountingType);

        for (uint256 i; i < d.pausers.length; ++i) {
            oft.setPauser(d.pausers[i], true);
        }

        for (uint256 i; i < d.remotes.length; ++i) {
            LZInit.wireOftPeer(address(oft), d.remotes[i].eid, d.remotes[i].cfg, d.remotes[i].rateLimits);
        }

        LZInit.updateGlobalRateLimits(address(oft), d.globalLimits);

        oft.setDelegate(d.gov);
        oft.transferOwnership(d.gov);
    }
}
