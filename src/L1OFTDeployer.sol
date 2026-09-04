// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { ERC1967Proxy }            from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { SkyOFTAdapter }           from "sky-oapp-oft/SkyOFTAdapter.sol";
import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits, OAppLike } from "lz-init-lib/LZInit.sol";

/// @notice One remote the adapter serves at go-live.
/// @dev    `rateLimits` stay at zero unless the bridge is meant to go live without a spell.
struct RemoteWiring {
    uint32     eid;
    OftConfig  cfg;
    RateLimits rateLimits;
}

/// @notice One struct rather than six parameters, which overflow the ABI decoder's stack.
/// @dev    `globalLimits` is the sentinel-bucket cap the lockbox checks on every transfer in either
///         direction, on top of the per-eid buckets: at zero it blocks all traffic until a spell sets
///         it. `aggregateAccountingType` is that bucket's own type, independent of the per-eid one.
struct L1OftDeployment {
    address                 token;
    RateLimitAccountingType accountingType;
    RateLimitAccountingType aggregateAccountingType;
    RateLimits              globalLimits;
    address[]               pausers;
    RemoteWiring[]          remotes;
}

/// @notice Deploys a mainnet Sky OFT lockbox, pre-configures it, and hands it to `MCD_PAUSE_PROXY`.
/// @dev    One instance per token: the token is an implementation immutable, and two implementations
///         in one deployer would push its initcode near the EIP-3860 limit.
///
///         A lockbox holds the backing rather than minting it, and caps the total across all remotes
///         on top of the per-eid buckets.
///
///         Wiring reuses `LZInit.wireOftPeer` rather than reimplementing it, so both ends of a route
///         come from one implementation.
contract L1OFTDeployer {

    SkyOFTAdapter public immutable implementation;
    SkyOFTAdapter public immutable oft;

    constructor(L1OftDeployment memory d) {
        address endpoint = OAppLike(LZInit.chainlog.getAddress("LZ_GOV_SENDER")).endpoint();

        implementation = new SkyOFTAdapter(d.token, endpoint);

        // `initialize` makes this contract owner and endpoint delegate, which is what lets the calls
        // below reach the OApp's setters and the endpoint's config setters.
        oft = SkyOFTAdapter(address(new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(SkyOFTAdapter.initialize, (address(this)))
        )));

        // Before any wiring: switching an accounting type later would leave accrued in-flight amounts
        // accounted under the old rule.
        oft.setRateLimitAccountingType(d.accountingType);
        oft.setAggregateRateLimitAccountingType(d.aggregateAccountingType);

        for (uint256 i; i < d.pausers.length; ++i) {
            oft.setPauser(d.pausers[i], true);
        }

        for (uint256 i; i < d.remotes.length; ++i) {
            LZInit.wireOftPeer(address(oft), d.remotes[i].eid, d.remotes[i].cfg, d.remotes[i].rateLimits);
        }

        LZInit.updateGlobalRateLimits(address(oft), d.globalLimits);

        address pauseProxy = LZInit.chainlog.getAddress("MCD_PAUSE_PROXY");
        oft.setDelegate(pauseProxy);
        oft.transferOwnership(pauseProxy);
    }
}
