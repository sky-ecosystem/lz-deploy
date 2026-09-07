// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { GovernanceOAppReceiver } from "sky-oapp-oft/GovernanceOAppReceiver.sol";
import { GovernanceRelayDeploy }  from "lz-governance-relay/deploy/GovernanceRelayDeploy.sol";

import { LZInit, UlnConfig, EndpointLike } from "lz-init-lib/LZInit.sol";

struct GovRecvConfig {
    address   recvLib;
    UlnConfig recvUlnCfg;
}

/// @notice Deploys a new chain's half of the Sky LZ governance bridge: the `GovernanceOAppReceiver`
///         and the `L2GovernanceRelay` that executes its messages behind a delay.
contract L2GovBridgeDeployer {

    uint32 internal constant ETH_EID = 30101;

    GovernanceOAppReceiver public immutable receiver;
    address                public immutable relay;

    /// @param l1GovSender The L1 `GovernanceOAppSender` (chainlog `LZ_GOV_SENDER`), the receiver's peer.
    /// @param l1GovRelay  The L1 `L1GovernanceRelay` (chainlog `LZ_GOV_RELAY`), the only sender whose
    ///                    messages this relay executes.
    /// @param bud         Addresses allowed to cancel queued actions.
    constructor(
        address              endpoint,
        address              l1GovSender,
        address              l1GovRelay,
        uint256              delay,
        uint256              gracePeriod,
        address[]     memory bud,
        GovRecvConfig memory cfg
    ) {
        receiver = new GovernanceOAppReceiver({
            _governanceOAppSenderEid:     ETH_EID,
            _governanceOAppSenderAddress: bytes32(uint256(uint160(l1GovSender))),
            _endpoint:                    endpoint,
            _owner:                       address(this)
        });

        relay = GovernanceRelayDeploy.deployL2({
            l1Eid:             ETH_EID,
            l2Oapp:            address(receiver),
            l1GovernanceRelay: l1GovRelay,
            delay:             delay,
            gracePeriod:       gracePeriod,
            bud:               bud
        });

        EndpointLike(endpoint).setReceiveLibrary({
            oapp:        address(receiver),
            eid:         ETH_EID,
            newLib:      cfg.recvLib,
            gracePeriod: 0
        });

        LZInit.setUlnConfig(address(receiver), ETH_EID, cfg.recvLib, cfg.recvUlnCfg);

        receiver.setDelegate(relay);
        receiver.transferOwnership(relay);
    }
}
