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
- **The SSR rate-provider adapters.** `SSRBalancerRateProviderAdapter` and
  `SSRChainlinkRateProviderAdapter` are unowned views over the oracle, so anyone can deploy one
  against `L2SsrBridgeDeployer.oracle()` once a consumer needs it.
- **The deployment scripts.** `script/examples/` holds unaudited examples of driving these deployers,
  partially pre-filled for one target remote and provided without guarantee. Each has to be filled in
  and re-checked in full against the deployment it is used for.
- **Stars governance**, which lz-init-lib does not cover either.
- **Solana governance and token bridging**, which has no Solidity equivalent.

Every deployment is assumed to be checked in full before a spell onboards it — by `lz-init-lib`'s own
sanity checks where it has them, and off-chain where it does not.

## Layout

```
src/L1OFTDeployer.sol            mainnet:   SkyOFTAdapter proxy, wired and handed to the pause proxy
src/L2OFTDeployer.sol            new chain: SkyOFTAdapterMintBurn proxy, wired and handed to the relay
src/L2GovBridgeDeployer.sol      new chain: GovernanceOAppReceiver + L2GovernanceRelay
src/L1SsrBridgeDeployer.sol      mainnet:   SSROracleForwarderLZ
src/L2SsrBridgeDeployer.sol      remote:    SSRAuthOracle + LZComposeReceiver
```

## Deployment and configuration sequence

These sequences are illustrative and not exhaustive.

### A new chain

1. The DVN infrastructure, from `lz-gov-dvns-deploy` — its replica addresses are inputs to step 2's
   governance ULN config.
2. `L2GovBridgeDeployer` — deploys the receiver and the relay every later step hands off to.
3. `LZL2Spell` — stateless and unowned, so no deployer owns it; its address is what a spell passes to
   `relayToL2`.
4. Per token: the token, then `L2OFTDeployer` against it — the adapter takes its token as a
   constructor immutable — then `rely` the adapter and the relay on that token and `deny` the
   deploying key.
5. The L1 spell — `LZDVNInit.wireCCIPDVN` for the new chain's route on the shared CCIP DVN adapter,
   then `wireGovPeer`, `wireOftPeer` and `activateOft`.

### An SSR bridge

Each half holds the other's address immutably, so the L2 deployer publishes where its receiver will
land and the forwarder is built against that.

1. `L2SsrBridgeDeployer(maxSSR, oracleAdmin)` on the remote — deploys the oracle, authorises the
   receiver of step 3 on it, and settles its admin role.
2. `L1SsrBridgeDeployer(dstEid, cfg)` on mainnet, `cfg.peer` set to
   `L2SsrBridgeDeployer.predictedReceiver()` — deploys the forwarder, wires its send side, and hands it
   to `MCD_PAUSE_PROXY`.
3. `deployReceiver(...)` on the remote — deploys the receiver, wires its receive side, and hands it to
   the relay.
4. The L1 spell — `activateSsrForwarder`.

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
