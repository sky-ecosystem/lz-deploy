// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { ERC1967Proxy }            from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { SkyOFTAdapterMintBurn }   from "sky-oapp-oft/SkyOFTAdapterMintBurn.sol";
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

/// @notice Everything a satellite adapter needs, in one struct: six flat parameters overflow the ABI
///         decoder's stack once two of them are nested dynamic arrays.
struct L2OftDeployment {
    address                 token;
    address                 endpoint;
    RateLimitAccountingType accountingType;
    address[]               pausers;
    RemoteWiring[]          remotes;
    address                 gov;
}

/// @notice Deploys a satellite Sky OFT adapter, pre-configures it to the state a spell later asserts
///         via `LZInit.activateOft`, and hands it to governance — all in the constructor.
/// @dev    One instance per token per chain: the token is an implementation immutable, and two
///         implementations in one deployer would push its initcode near the EIP-3860 limit.
///
///         Everything is atomic because nothing has to wait: every input, the peers included, is
///         known before the first deployment.
///
///         Wiring is `LZInit.wireOftPeer` itself, the code a spell runs on the other side of the
///         route, so both ends come from one implementation.
contract L2OFTDeployer {

    SkyOFTAdapterMintBurn public immutable implementation;
    SkyOFTAdapterMintBurn public immutable oft;

    /// @param d `token`          the underlying ERC20; it must be given mint/burn authority over the
    ///                              adapter separately, which is out of scope here
    ///          `endpoint`       the LayerZero EndpointV2 on this chain
    ///          `accountingType` asserted verbatim by `activateOft`; applied before any wiring, since
    ///                              switching later would leave in-flight amounts on the old rule
    ///          `pausers`        granted the ability to pause the adapter
    ///          `remotes`        every remote the adapter serves at go-live, not just L1: a spell
    ///                              wiring a new chain only relays `wireOftPeer` on the existing sides
    ///          `gov`            the chain's L2GovernanceRelay; `activateOft` asserts owner and
    ///                              delegate are the same address, so both move together
    constructor(L2OftDeployment memory d) {

        implementation = new SkyOFTAdapterMintBurn(d.token, d.endpoint);

        // `initialize` makes this contract both owner and endpoint delegate, which is what lets the
        // calls below reach the OApp's setters and the endpoint's config setters.
        oft = SkyOFTAdapterMintBurn(address(new ERC1967Proxy(
            address(implementation),
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
