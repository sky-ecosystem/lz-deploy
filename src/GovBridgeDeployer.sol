// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.24;

import { GovernanceOAppReceiver } from "sky-oapp-oft/GovernanceOAppReceiver.sol";
import { GovernanceRelayDeploy }  from "lz-governance-relay/deploy/GovernanceRelayDeploy.sol";

import { LZInit, UlnConfig, EndpointLike } from "lz-init-lib/LZInit.sol";

interface OAppAdminLike {
    function setDelegate(address delegate) external;
    function transferOwnership(address newOwner) external;
}

// Note: DVN arrays in `recvUlnCfg` must be strictly ascending by address. For the governance bridge
// this is the three-wing set from `lz-dvn-broadcaster` (LZ-aligned DVNs plus the CCIP and multisig
// `DVNReplica`s, threshold above any single wing); the replicas come from `lz-gov-dvns-deploy`.
struct GovRecvConfig {
    address   recvLib;
    UlnConfig recvUlnCfg;
}

/// @notice Deploys a new chain's half of the Sky LZ governance bridge: the `GovernanceOAppReceiver`
///         and the `L2GovernanceRelay` that executes its messages behind a delay.
/// @dev    Everything in the constructor, ending owned by the relay. There is no bring-up window to
///         use: the L1 send side (`LZInit.wireGovPeer`) is a spell action, so the first message
///         across the bridge is the spell's own.
contract GovBridgeDeployer {

    uint32 internal constant ETH_EID = 30101;

    address public immutable receiver;
    address public immutable relay;

    event Deployed(address indexed receiver, address indexed relay);

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
        require(l1GovSender != address(0), "GovBridgeDeployer/gov-sender-is-zero");
        require(l1GovRelay  != address(0), "GovBridgeDeployer/gov-relay-is-zero");
        require(cfg.recvLib != address(0), "GovBridgeDeployer/recv-lib-is-zero");

        // Ordering is forced: the receiver sets its peer in its own constructor and the relay takes
        // it as an immutable, and owning it here keeps this contract the delegate for the config below.
        receiver = address(new GovernanceOAppReceiver({
            _governanceOAppSenderEid:     ETH_EID,
            _governanceOAppSenderAddress: bytes32(uint256(uint160(l1GovSender))),
            _endpoint:                    endpoint,
            _owner:                       address(this)
        }));

        relay = GovernanceRelayDeploy.deployL2({
            l1Eid:             ETH_EID,
            l2Oapp:            receiver,
            l1GovernanceRelay: l1GovRelay,
            delay:             delay,
            gracePeriod:       gracePeriod,
            bud:               bud
        });

        // Pinned rather than left to the endpoint default: the DVN set below is meaningless if the
        // packet is verified through another library, and the broadcaster design assumes it is set.
        EndpointLike(endpoint).setReceiveLibrary({
            oapp:        receiver,
            eid:         ETH_EID,
            newLib:      cfg.recvLib,
            gracePeriod: 0
        });

        LZInit.setUlnConfig(receiver, ETH_EID, cfg.recvLib, cfg.recvUlnCfg);

        // Delegate first: after `transferOwnership` this contract can no longer set it.
        OAppAdminLike(receiver).setDelegate(relay);
        OAppAdminLike(receiver).transferOwnership(relay);

        emit Deployed(receiver, relay);
    }
}
