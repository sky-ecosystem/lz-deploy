// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { ERC1967Proxy }            from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { SkyOFTAdapter }           from "sky-oapp-oft/SkyOFTAdapter.sol";
import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits, OAppLike } from "lz-init-lib/LZInit.sol";

/// @notice One remote the adapter serves at go-live.
struct RemoteWiring {
    uint32     eid;
    OftConfig  cfg;
    RateLimits rateLimits;
}

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
contract L1OFTDeployer {

    address       public immutable implementation;
    SkyOFTAdapter public immutable oft;

    constructor(L1OftDeployment memory d) {
        address endpoint = OAppLike(LZInit.chainlog.getAddress("LZ_GOV_SENDER")).endpoint();

        implementation = address(new SkyOFTAdapter(d.token, endpoint));

        oft = SkyOFTAdapter(address(new ERC1967Proxy(
            implementation,
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

        address pauseProxy = LZInit.chainlog.getAddress("MCD_PAUSE_PROXY");
        oft.setDelegate(pauseProxy);
        oft.transferOwnership(pauseProxy);
    }
}
