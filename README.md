# lz-deploy

Deployment and wiring contracts for Sky's LayerZero OApps — the deployer-side counterpart to
[`lz-init-lib`](https://github.com/sky-ecosystem/lz-init-lib).

`lz-init-lib` is a library for governance *spells*, and every one of its functions assumes the
contracts it operates on were "deployed and pre-configured by the deployer beforehand". This repo is
that step, in Solidity: auditable deployer contracts that bring an OApp — on a new chain or on mainnet
— to the exact state a spell asserts, then hand ownership to governance.

## Scope

Supported:

- **Bringing a new chain onto SkyLink** — `GovernanceOAppReceiver` + `L2GovernanceRelay`, and one
  `SkyOFTAdapterMintBurn` (behind a UUPS proxy) per token, wired to every remote it serves at go-live
  and handed to the relay.
- **Mainnet OFT lockboxes** — one `SkyOFTAdapter` (behind a UUPS proxy) per token, wired, given its
  global cap and handed to `MCD_PAUSE_PROXY`.
- **SSR oracle bridges over LayerZero** — the mainnet `SSROracleForwarderLZ`, and the remote oracle and
  receiver.

Out of scope, by design:

- **DVN infrastructure.** The CCIP DVN adapter, `DVNBroadcaster`s and `DVNReplica`s come from
  [`lz-gov-dvns-deploy`](https://github.com/sky-ecosystem/lz-gov-dvns-deploy) and
  [`lz-dvn-broadcaster`](https://github.com/sky-ecosystem/lz-dvn-broadcaster). Their addresses are
  inputs here.
- **Tokens and their mint/burn authority.** The token is an input, not an output: both OFT deployers
  take the ERC20 as a parameter and never touch its wards. Deploying the L2 token and granting the L2
  adapter authority over it happen elsewhere.
- **Stars governance**, which lz-init-lib does not cover either.
- **Solana governance and token bridging**, which has no Solidity equivalent.

## Layout

```
src/L1OFTDeployer.sol            mainnet:   SkyOFTAdapter proxy, wired and handed to the pause proxy
src/L2OFTDeployer.sol            new chain: SkyOFTAdapterMintBurn proxy, wired and handed to the relay
src/L2GovBridgeDeployer.sol      new chain: GovernanceOAppReceiver + L2GovernanceRelay
src/SsrForwarderDeployer.sol     mainnet:   SSROracleForwarderLZ
src/SsrRemoteDeployer.sol        remote:    SSRAuthOracle + LZComposeReceiver
```

## Deployment and configuration sequence

### A new chain

1. The DVN infrastructure, from `lz-gov-dvns-deploy` — its replica addresses are inputs to step 2's
   governance ULN config.
2. `L2GovBridgeDeployer` — deploys the receiver and the relay every later step hands off to.
3. The chain's tokens — each adapter takes its token as a constructor immutable.
4. `L2OFTDeployer`, one per token — deploys and wires an adapter; `rely` it on its token afterwards.
5. `LZL2Spell` — stateless and unowned, so no deployer owns it; its address is what a spell passes to
   `relayToL2`.
6. The L1 spell — `wireGovPeer`, `wireOftPeer`, `activateOft`.

### An SSR bridge

Each half holds the other's address immutably, so the remote deployer publishes where its receiver
will land and the forwarder is built against that.

1. `SsrRemoteDeployer(maxSSR, oracleAdmin)` on the remote — deploys the oracle, authorises the
   receiver of step 3 on it, and settles its admin role.
2. `SsrForwarderDeployer(dstEid, cfg)` on mainnet, `cfg.peer` set to
   `SsrRemoteDeployer.predictedReceiver()` — deploys the forwarder, wires its send side, and hands it
   to `MCD_PAUSE_PROXY`.
3. `deployReceiver(...)` on the remote — deploys the receiver, wires its receive side, and hands it to
   the relay.
4. The L1 spell — `activateSsrForwarder`.

Nothing can be sent before step 4: it whitelists the forwarder on the shared CCIP DVN adapter.

## Build

```bash
git submodule update --init --recursive
pnpm install --frozen-lockfile
forge build
```

## Test

```bash
MAINNET_RPC_URL=<mainnet_rpc> forge test
```
