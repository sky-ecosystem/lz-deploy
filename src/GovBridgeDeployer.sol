// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { GovernanceOAppReceiver } from "sky-oapp-oft/GovernanceOAppReceiver.sol";
import { GovernanceRelayDeploy }  from "lz-governance-relay/deploy/GovernanceRelayDeploy.sol";
import { L2GovernanceRelay }      from "lz-governance-relay/src/L2GovernanceRelay.sol";

import { LZInit, UlnConfig, EndpointLike } from "lz-init-lib/LZInit.sol";
import { LZL2Spell }                      from "lz-init-lib/LZL2Spell.sol";

// Note: DVN arrays in `recvUlnCfg` must be strictly ascending by address. For the governance bridge
// this is the three-wing set from `lz-dvn-broadcaster` (LZ-aligned DVNs plus the CCIP and multisig
// `DVNReplica`s, threshold above any single wing); the replicas come from `lz-gov-dvns-deploy`.
struct GovRecvConfig {
    address   recvLib;
    UlnConfig recvUlnCfg;
}

/// @notice Deploys a new chain's half of the Sky LZ governance bridge: the `GovernanceOAppReceiver`,
///         the `L2GovernanceRelay` that executes its messages behind a delay, and the `LZL2Spell`
///         the relay delegatecalls to run LZ configuration relayed from L1.
/// @dev    Everything in the constructor, ending owned by the relay. There is no bring-up window to
///         use: the L1 send side (`LZInit.wireGovPeer`) is a spell action, so the first message
///         across the bridge is the spell's own.
contract GovBridgeDeployer {

    uint32 internal constant ETH_EID = 30101;

    GovernanceOAppReceiver public immutable receiver;
    L2GovernanceRelay      public immutable relay;
    LZL2Spell              public immutable l2Spell;

    event Deployed(address indexed receiver, address indexed relay, address indexed l2Spell);

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

        // Ordering is forced: the receiver sets its peer in its own constructor and the relay takes
        // it as an immutable, and owning it here keeps this contract the delegate for the config below.
        receiver = new GovernanceOAppReceiver({
            _governanceOAppSenderEid:     ETH_EID,
            _governanceOAppSenderAddress: bytes32(uint256(uint160(l1GovSender))),
            _endpoint:                    endpoint,
            _owner:                       address(this)
        });

        relay = L2GovernanceRelay(GovernanceRelayDeploy.deployL2({
            l1Eid:             ETH_EID,
            l2Oapp:            address(receiver),
            l1GovernanceRelay: l1GovRelay,
            delay:             delay,
            gracePeriod:       gracePeriod,
            bud:               bud
        }));

        // Pinned rather than left to the endpoint default: the DVN set below is meaningless if the
        // packet is verified through another library, and the broadcaster design assumes it is set.
        EndpointLike(endpoint).setReceiveLibrary({
            oapp:        address(receiver),
            eid:         ETH_EID,
            newLib:      cfg.recvLib,
            gracePeriod: 0
        });

        LZInit.setUlnConfig(address(receiver), ETH_EID, cfg.recvLib, cfg.recvUlnCfg);

        // Stateless and unowned: the relay takes its delegatecall target per message, so this only
        // has to exist and be known to the L1 spell author.
        l2Spell = new LZL2Spell();

        // Delegate first: after `transferOwnership` this contract can no longer set it.
        receiver.setDelegate(address(relay));
        receiver.transferOwnership(address(relay));

        emit Deployed(address(receiver), address(relay), address(l2Spell));
    }
}
