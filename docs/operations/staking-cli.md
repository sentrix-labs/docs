# Staking CLI (`sentrix staking …`)

TX-based staking operations — the proper consensus-safe path for validator + delegator state changes. Use these instead of `sentrix validator unjail` / `force-unjail`, which mutate the stake registry directly in the database without updating the state trie and require a cluster-wide trie reconciliation to recover.

Every command here builds a signed transaction targeted at `PROTOCOL_TREASURY`, queues it in the local mempool, and lets the chain's normal `apply_block` path execute the op — so the state trie stays consistent on every peer that re-executes the block.

Shipped in **v2.2.22**.

## Common arguments

| Flag | Description |
|---|---|
| `--keystore <path>` | Path to the sender's Argon2id v2 keystore file. Password comes from the `SENTRIX_WALLET_PASSWORD` env var, or is read from stdin via a non-echoing prompt if the env var is unset. |
| `--fee <sentri>` | Transaction fee in sentri (1 SRX = 100,000,000 sentri). Defaults to 10,000 sentri (0.0001 SRX) on every command. |

Run while the chain process for that node is stopped — the CLI takes an exclusive lock on `chain.db`. When the node starts again, the queued tx is gossiped via libp2p mempool and an active proposer includes it in the next block.

## `sentrix staking register`

Register the sender as a validator candidate. The wallet must hold at least `self_stake + fee` SRX. On apply, `self_stake` is escrowed into `PROTOCOL_TREASURY` and the sender enters the candidate pool; active set entry happens at the next epoch boundary if total stake ranks in the top 21.

```bash
sentrix staking register \
  --keystore /path/to/my-validator.keystore \
  --self-stake 15000 \
  --commission-rate 1000 \
  --fee 10000
```

| Argument | Meaning |
|---|---|
| `--self-stake` | Bonded SRX, whole units. Must be ≥ `MIN_SELF_STAKE` (15,000 SRX). |
| `--commission-rate` | Basis points (1000 = 10%, max 10000 = 100%). |

After the tx applies, query `/staking/validators/<addr>` to confirm registration. Verify the entry's `is_active` flips to `true` at the next epoch (28,800 blocks ≈ 1 day at 1s blocks).

## `sentrix staking add-self-stake`

Top up the sender's `self_stake` by `--amount` SRX. The most common use is unblocking a jailed validator whose `self_stake` fell below `MIN_SELF_STAKE` after a downtime slash — the dispatcher's `unjail()` floor check rejects until the validator is back above the threshold.

```bash
sentrix staking add-self-stake \
  --keystore /path/to/my-validator.keystore \
  --amount 15 \
  --fee 10000
```

**Fork dependency:** `AddSelfStake` dispatch is gated by `ADD_SELF_STAKE_HEIGHT`. Defaults:

| Chain | Default activation | Notes |
|---|---|---|
| Sentrix Testnet (7120) | **h=5,800,000** (active since v2.2.22) | Set 2026-05-30 to recover the 2026-05-30 stall artifact. |
| Sentrix Chain mainnet (7119) | `u64::MAX` (disabled) | Pending a planned activation window. |

Operators can override either chain via `ADD_SELF_STAKE_HEIGHT=<height>` env, but every peer in the active set must agree on the value or consensus will fork at the activation boundary.

If the tx applies before the fork activates, the dispatcher returns `gated by ADD_SELF_STAKE_HEIGHT fork (currently disabled)` and the sender's fee is consumed for the failed attempt.

## `sentrix staking unjail`

Submit an Unjail tx — the proper TX-based path. Goes through `apply_block` so `state_trie` stays consistent.

```bash
sentrix staking unjail \
  --keystore /path/to/my-validator.keystore \
  --fee 10000
```

Requirements:

- `self_stake ≥ MIN_SELF_STAKE` (use `add-self-stake` first if slashed below)
- `current_height ≥ jail_until` (jail period expired — `DOWNTIME_JAIL_BLOCKS = 600` blocks ≈ 10 min after the original jail event)
- Validator is not `is_tombstoned` (permanent ban — no recovery)

This is the recommended path. Do not use `sentrix validator unjail` or `sentrix validator force-unjail` unless the chain is so stuck that no transaction can be mined — those edit the DB directly and the warning printed by the CLI documents the cluster-wide recovery required.

## `sentrix staking claim-rewards`

Drain the sender's accumulated pending-rewards (validator-side + delegator-side) from `PROTOCOL_TREASURY` into their account balance.

```bash
sentrix staking claim-rewards \
  --keystore /path/to/my-validator.keystore \
  --fee 10000
```

No arguments beyond the keystore and fee. The dispatcher reads `pending_rewards` for the sender, peek-then-transfer-then-drains the accumulators (audit H5, 2026-05-06).

## End-to-end recovery example (val3, 2026-05-30 testnet)

Val3 was jailed during the 2026-05-30 stall recovery with `self_stake = 14,985 SRX` (0.1% downtime slash brought it below the 15,000 SRX floor). Recovery procedure once `ADD_SELF_STAKE_HEIGHT` activates on testnet at h=5,800,000:

```bash
# 1. Pull rewards into the wallet so we have spendable SRX
sentrix staking claim-rewards \
  --keystore /opt/sentrix-testnet-docker/data/val3/wallets/sentrix-testnet-val3.keystore \
  --fee 10000

# 2. Top up self_stake back above MIN_SELF_STAKE
sentrix staking add-self-stake \
  --keystore /opt/sentrix-testnet-docker/data/val3/wallets/sentrix-testnet-val3.keystore \
  --amount 15

# 3. Unjail — dispatcher's floor check now passes
sentrix staking unjail \
  --keystore /opt/sentrix-testnet-docker/data/val3/wallets/sentrix-testnet-val3.keystore
```

Start the val3 container after step 3 completes; the mempool gossips the queued txs, an active proposer includes them, and val3 rejoins the active set at the next epoch boundary.

## Comparison with `sentrix validator unjail` / `force-unjail`

| Property | `sentrix staking …` (this page) | `sentrix validator unjail` / `force-unjail` |
|---|---|---|
| State change goes through | Block apply path | Direct DB write |
| Updates `state_trie` | Yes (apply_block recomputes) | **No** — leaves trie hash stale |
| Verify-deep on peers | Passes | **Fails** until cluster-wide trie rebuild |
| Cluster-wide outage required | No (single-node CLI run, peers gossip the tx) | Yes (halt-all, reset-trie, tar-pipe, simul-start) |
| Phantom stake risk | None — tx.amount comes from sender balance | Yes for `force-unjail` (restores stake without minting) |

Use the TX path whenever the chain can still mine blocks. Direct-DB commands are break-glass only — keep them around for the case where the chain is so stuck that no transaction can mine.
