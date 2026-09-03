# lz-deploy

Deployment and wiring contracts for Sky's LayerZero OApps — the deployer-side counterpart to
[`lz-init-lib`](https://github.com/sky-ecosystem/lz-init-lib).

`lz-init-lib` is a library for governance *spells*, and every one of its functions assumes the
remote contracts were "deployed and pre-configured by the deployer beforehand". This repo is that
step, in Solidity: auditable deployer contracts that take a new chain from nothing to the exact state
a spell asserts, then hand ownership to governance. It replaces the hardhat-deploy scripts, LayerZero
devtools config graphs and one-off tasks in [`sky-oapp-oft`](https://github.com/sky-ecosystem/sky-oapp-oft),
following the factory style of [`lz-gov-dvns-deploy`](https://github.com/sky-ecosystem/lz-gov-dvns-deploy).

## Scope

Supported:

- **Bringing a new chain onto SkyLink** — `GovernanceOAppReceiver` + `L2GovernanceRelay` + the
  `LZL2Spell` the relay delegatecalls, and one
  `SkyOFTAdapterMintBurn` (behind a UUPS proxy) per token, wired to every remote it serves at go-live.
- **SSR oracle bridges over LayerZero** — the mainnet `SSROracleForwarderLZ`, and the remote oracle,
  rate-provider adapters and receiver.

> **Disclaimer — existing tokens only.** This repo brings new *chains* onto the **existing USDS and
> sUSDS** bridges, whose L1 lockboxes (`SkyOFTAdapter`) already exist post-Avalanche-migration. It
> does **not** deploy an L1 lockbox, so it cannot onboard a *new* OFT token. Doing that needs a
> lockbox deployer (`SkyOFTAdapter` proxy + its pre-config + handover to `MCD_PAUSE_PROXY`), which is
> deliberately not here.

Out of scope, by design:

- **The L1 and incumbent-L2 sides of a new pathway.** Those are governance actions:
  `LZInit.wireGovPeer`, `wireOftPeer`, `activateOft`, `activateSsrForwarder`.
- **DVN infrastructure.** The CCIP DVN adapter, `DVNBroadcaster`s and `DVNReplica`s come from
  [`lz-gov-dvns-deploy`](https://github.com/sky-ecosystem/lz-gov-dvns-deploy) and
  [`lz-dvn-broadcaster`](https://github.com/sky-ecosystem/lz-dvn-broadcaster). Their addresses are
  *inputs* here.
- **Tokens and mint/burn authority.** The new chain's USDS/sUSDS, and the `rely` that lets each
  adapter mint and burn, are separate steps. **The bridge is inert until that authority is granted** —
  sequence it explicitly.
- **Solana.** `sky-oapp-oft`'s Solana tasks have no Solidity equivalent and stay where they are.

## Design

**Built to the verifier.** `LZInit._verifyOftConfig` and `_verifyForwarderConfig` enumerate the
terminal state governance asserts before turning a bridge on: peer set, send and receive libraries
pinned (not defaults), executor and ULN configs byte-equal, enforced options in one exact encoding,
fees zero, per-eid rate limits zero, not paused, no message inspector, and owner == endpoint delegate
== governance. Those checks are the specification for the deployers here, so the tests are written as
acceptance tests: deploy, hand off, then run lz-init-lib's own function and require that it does not
revert.

The OFT deployers go further and call **`LZInit.wireOftPeer` itself** — the same code a spell runs on
the other side of the route. The two ends of a pathway are configured by one implementation rather
than two that have to be kept in agreement.

**Deployer holds admin, then hands off.** Each deployer contract owns what it deploys and is the
LayerZero endpoint delegate for it during bring-up (which is what lets it call the endpoint's config
setters at all), and hands both to governance in one irreversible step. Delegate first, then
ownership: the reverse order strands the delegate.

| Contract | Chain | Shape |
| --- | --- | --- |
| `src/L1OFTDeployer.sol` | mainnet | single constructor, ends owned by the pause proxy |
| `src/L2OFTDeployer.sol` | new chain | single constructor, ends owned by the relay |
| `src/GovBridgeDeployer.sol` | new chain | single constructor, ends owned by the relay |
| `src/SsrRemoteDeployer.sol` | remote | constructor → `deployReceiver` → `handOff` |
| `src/SsrForwarderDeployer.sol` | mainnet | constructor → `configure` → `handOff` |

`GovBridgeDeployer` and both OFT deployers do everything in their constructors because there is
nothing to do between steps: every input is known up front, and nothing they deploy can be tested
before a spell wires the far side. `SsrForwarderDeployer` and `SsrRemoteDeployer` are staged because
the receiver address must be predicted before the forwarder exists (below), and because their bridge
is the one that can actually be tested before a spell.

**One OFT deployer per token.** The adapter implementation takes its token as a constructor
immutable, so each deployer embeds one implementation's creation code — ~28KB of initcode against the
EIP-3860 limit of 49,152. Two implementations in one deployer (~45KB) would sit uncomfortably close to
it. `forge build --sizes` prints the current margins.

**The SSR bridge follows xchain-ssr-oracle's `lz-deploy-sequence.md`**, with its four phases split
across the two deployers: deploy + `maxSSR` (phase 1), `setPeer` / enforced options / routing on both
endpoints (phase 2), a live `drip()` + `refresh()` (phase 3), then `handOff` on each side (phase 4).
Two deliberate differences: the receiver address is predicted and asserted on-chain rather than from an
EOA's nonce across two forks (below), and each `handOff` moves delegate *and* ownership for its own side
in one call rather than doing all delegates then all ownerships — the same end state, and it cannot
strand the delegate. The oracle's admin is also renounced at handoff rather than at deployment, so
`setMaxSSR` stays reachable through the smoke test.

Note the consequence of the immutables, from that runbook: replacing the forwarder means replacing
every receiver, and if the oracle's admin was renounced, every oracle too.

**Circular immutables in the SSR bridge.** The forwarder holds the receiver address immutably and the
receiver holds the forwarder as its immutable `sourceAuthority`, so neither can be deployed second
with full knowledge of the other. `SsrRemoteDeployer.predictedReceiver()` publishes the address its
`deployReceiver` will use (a `CREATE` address, independent of constructor arguments) and asserts the
receiver lands there. `xchain-ssr-oracle`'s own script predicts an EOA's nonce across two forks
instead; keeping the arithmetic on-chain makes it *asserted* rather than assumed.

## Layout

```
src/L1OFTDeployer.sol          mainnet:   SkyOFTAdapter proxy, wired and handed to the pause proxy
src/L2OFTDeployer.sol          new chain: SkyOFTAdapterMintBurn proxy, wired and handed to the relay
src/GovBridgeDeployer.sol      new chain: GovernanceOAppReceiver + L2GovernanceRelay + LZL2Spell
src/SsrForwarderDeployer.sol   mainnet:   SSROracleForwarderLZ
src/SsrRemoteDeployer.sol      remote:    SSRAuthOracle + adapters + LZComposeReceiver
src/LzOptions.sol              the enforced-options encoding spells assert against
script/DeployNewChain.s.sol    template: a new chain's full bring-up
script/DeploySsrBridge.s.sol   template: an SSR bridge across two forks
```

Scripts are **templates**: DVN sets, libraries, confirmations and gas are per-chain and must be
filled in and reviewed per deployment. They are deliberately explicit rather than defaulted, because
each value is something a spell later asserts on-chain.

## Build

Solidity sources for LayerZero and OpenZeppelin come from npm, pinned to the versions
`sky-oapp-oft`'s lockfile resolves, so the contracts compile against exactly the sources they were
audited against. Everything else is a submodule.

```bash
git submodule update --init --recursive
pnpm install --ignore-scripts
forge build
```

Use pnpm: `@layerzerolabs/oapp-evm-upgradeable@0.1.3` declares a peer dependency on
`lz-evm-messagelib-v2@^3.0.148` while `sky-oapp-oft` resolves 3.0.139. pnpm accepts that (as upstream
does); npm needs `--legacy-peer-deps`.

`remappings.txt` maps the unprefixed `layerzerolabs/` and `openzeppelin-contracts/` spellings used by
`xchain-helpers` and `xchain-ssr-oracle` onto those same npm packages. Without that, they would
resolve to `xchain-helpers`' own LayerZero-v2 and devtools submodules — a *different* set of
LayerZero sources than `sky-oapp-oft` compiles against, in one build. (Those submodules are still
fetched: `forge build` initialises everything in the tree recursively, ~40MB of it unused.)

## Test

```bash
MAINNET_RPC_URL=<mainnet_rpc> forge test
```

The suite forks mainnet pinned to block 24871363 — the same pin lz-init-lib uses — so the RPC must be
archive-capable, as that repo's suite requires. Every contract under test is deployed fresh, so
nothing actually depends on that height; `FORK_BLOCK=0 forge test` runs against the latest block and
works on a non-archive RPC.

The remote-side deployers are exercised on a mainnet fork too: what they configure is endpoint and
OApp state, which is chain-agnostic, and their L2-specific inputs (token, relay, DVN set) are
parameters — exactly how they are driven in production.

The tests worth reading first are the acceptance ones, each of which runs the real lz-init-lib
function against freshly deployed state:

- `test_activateOftAcceptsDeployedState` — `LZInit.activateOft` on an `L2OFTDeployer` result
- `test_wireGovPeerAcceptsDeployedReceiver` — `LZInit.wireGovPeer` against a `GovBridgeDeployer` result
- `test_activateSsrForwarderAcceptsDeployedState` — `LZInit.activateSsrForwarder` on the SSR pair

### What can be tested live, before the spell

Only the SSR bridge, end to end: both halves are deployed here and `refresh()` is permissionless, so
`sUSDS.drip()` then `refresh()` should land on the remote oracle before any handoff — unless the send
DVN set includes the shared CCIP DVN adapter, whose allowlist is deny-by-default until
`activateSsrForwarder` grants it.

The OFT and governance bridges cannot be: their far sides are wired by the spell, and OFT rate limits
are 0 until `activateOft`. For an OFT, `quoteSend` is the most that can be checked live — it exercises
the send library, executor and DVN fee config without moving anything. That is why the acceptance tests
above carry the weight they do: they are the only pre-spell evidence that the configuration is right.

## Open questions

1. **SSR enforced options vs. compose — fixed in lz-init-lib, pending review.**
   `_verifyForwarderConfig` compared the forwarder's msgType-1 enforced options against *exactly* one
   lzReceive option. But the remote is an `LZComposeReceiver`: `_lzReceive` only calls
   `endpoint.sendCompose` and the oracle write happens in `lzCompose`, which needs its own executor
   option. Leaving that to each `refresh()` caller's `extraOptions` strands delivered updates in the
   compose queue until someone pokes `lzCompose` manually, and contradicts both
   xchain-ssr-oracle's own deploy sequence ("`setEnforcedOptions` including both
   `addExecutorLzReceiveOption` and `addExecutorLzComposeOption`") and the assumption Sky gave the
   auditors — "we can assume that the enforced options are set correctly to cover the necessary gas
   cost" ([discussion](https://github.com/cantinasec/sky-review-030426/pull/80#discussion_r3123737074)).

   `ForwarderConfig` now carries a `composeGas` and the assertion covers lzReceive + lzCompose
   unconditionally — so a defaulted field can no longer change *which shape* gets verified, it just
   fails the hash comparison like any other wrong value. Both option `value` fields stay 0: native sent
   to an LZ receiver has no withdrawal path (v1.2.0 Cantina review, informational 3.1.2) and the oracle
   target is not payable. The change belongs to lz-init-lib PR #7, which introduced the whole forwarder
   surface — not PR #6, whose branch does not contain it.

   `SsrForwarderDeployer` sets both options; `LzOptions.encodeLzReceiveAndComposeOptions` is pinned against
   LayerZero's `OptionsBuilder`.

2. **`lz-governance-relay` is pinned to the unmerged `relay-timelock` branch**, the delay/freezer relay
   the Avalanche migration hands over to. Re-pin when it lands on `master`.
3. **Rate limits for a brand-new chain.** The deployers leave per-eid limits at zero so governance
   turns the bridge on via `activateOft`, which requires zero. lz-init-lib's README example for a new
   chain shows no `activateOft` on the new side, implying the deployer sets them there; both are
   supported (both OFT deployers take per-remote limits), but zero is the default.
4. **`xchain-ssr-oracle` is pinned to `master`**, not the `lz-gov-bridge-support` branch: that work
   merged (PR #48) and the branch was deleted. `master`'s forwarder is byte-identical to the branch's.
