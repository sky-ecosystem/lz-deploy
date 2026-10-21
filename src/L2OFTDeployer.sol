// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { ERC1967Proxy }            from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { SkyOFTAdapterMintBurn }   from "sky-oapp-oft/SkyOFTAdapterMintBurn.sol";
import { RateLimitAccountingType } from "sky-oapp-oft/interfaces/ISkyRateLimiter.sol";

import { LZInit, OftConfig, RateLimits } from "lz-init-lib/LZInit.sol";

/// @notice One remote the adapter serves at go-live.
struct RemoteWiring {
    uint32     eid;
    OftConfig  cfg;
    RateLimits rateLimits;
}

struct L2OftDeployment {
    address                 token;
    address                 endpoint;
    RateLimitAccountingType accountingType;
    address[]               pausers;
    RemoteWiring[]          remotes;
    address                 gov;
}

/// @notice Deploys an L2 Sky OFT adapter, pre-configures it, and hands it to governance.
/// @dev    One instance per token per chain: the token is an implementation immutable, and two
///         implementations in one deployer would push its initcode near the EIP-3860 limit.
contract L2OFTDeployer {

    address               public immutable implementation;
    SkyOFTAdapterMintBurn public immutable oft;

    constructor(L2OftDeployment memory d) {
        implementation = address(new SkyOFTAdapterMintBurn(d.token, d.endpoint));

        oft = SkyOFTAdapterMintBurn(address(new ERC1967Proxy(
            implementation,
            abi.encodeCall(SkyOFTAdapterMintBurn.initialize, (address(this)))
        )));

        oft.setRateLimitAccountingType(d.accountingType);

        for (uint256 i; i < d.pausers.length; ++i) {
            oft.setPauser(d.pausers[i], true);
        }

        for (uint256 i; i < d.remotes.length; ++i) {
            LZInit.wireOftPeer(address(oft), d.remotes[i].eid, d.remotes[i].cfg, d.remotes[i].rateLimits);
        }

        oft.setDelegate(d.gov);
        oft.transferOwnership(d.gov);
    }
}
