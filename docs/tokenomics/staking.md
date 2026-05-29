# Staking

Sentrix runs Voyager (DPoS + BFT finality) on both networks since 2026-04-25 — anyone with ≥15,000 SRX can register as a validator, anyone with any SRX balance can delegate.

## Validator set

| | Value | Citation |
|---|---|---|
| Max active validators | **21** | `MAX_ACTIVE_VALIDATORS` in `crates/sentrix-staking/src/staking.rs:13` |
| Min self-stake to register | **15,000 SRX** | `MIN_SELF_STAKE` in `staking.rs:12` |
| Min total active count | 4 (BFT 3-of-4 quorum floor) | `MIN_BFT_VALIDATORS` in `staking.rs:21` |
| Epoch length | 28,800 blocks (~1 day @ 1s) | `EPOCH_LENGTH` in `crates/sentrix-staking/src/epoch.rs:10` |
| Active-set recompute | Every epoch boundary | — |

Active set = top 21 by `self_stake + delegated_stake`. Recalculated at every epoch boundary.

## Delegation

Anyone can delegate SRX to a validator via `StakingOp::Delegate`. You keep ownership; the validator gets voting weight + block-producing rights proportional to total stake.

Rewards split: validator takes commission (validator-set basis-points, anything 0–10,000), delegators share the rest pro-rata. Claim manually via `StakingOp::ClaimRewards` (no auto-compound).

To exit: `StakingOp::Undelegate` initiates a 7-day unbonding period, then SRX returns to your balance.

## Slashing

All slash amounts are **basis points** (1 bp = 0.01%, so 100 bp = 1%).

### Liveness (offline / downtime)

| | Value | Citation |
|---|---|---|
| Rolling window | 14,400 blocks (~4h @ 1s) | `LIVENESS_WINDOW` in `slashing/liveness.rs:35` |
| Min signed per window | 4,320 blocks (30%) | `MIN_SIGNED_PER_WINDOW` in `liveness.rs:55` |
| Slash on jail | **10 bp = 0.1%** of self-stake | `DOWNTIME_SLASH_BP` in `liveness.rs:67` |
| Jail duration | 600 blocks (10 min @ 1s) | `DOWNTIME_JAIL_BLOCKS` in `liveness.rs:77` |

Validator must sign ≥30% of blocks in any rolling 4-hour window. If signed-blocks-in-window drops below 4,320, validator is jailed for 10 minutes + slashed 0.1% of self-stake. After jail expires, validator must submit `StakingOp::Unjail` to rejoin the active set.

Real-world downtime tolerance:
- Weekly 10-min deploy → 0.07% downtime (absorbed)
- Emergency 30-min recovery → 12.5% downtime (absorbed)
- Extended 2-hour debugging → 50% downtime (absorbed)
- Full 3-hour outage in a 4-hour window → 75% downtime (jailed + slashed)

### Safety (equivocation / malicious)

| | Value | Citation |
|---|---|---|
| Double-sign slash | **2,000 bp = 20%** of self-stake | `DOUBLE_SIGN_SLASH_BP` in `slashing/double_sign.rs:27` |
| Post-slash state | Tombstoned (permanent ban, no unjail path) | `is_tombstoned` flag in `staking.rs` |

Double-signing or tx manipulation triggers an immediate 20% slash plus tombstone (permanent kick from the active set, no recovery). 200× stricter than liveness, by design.

Delegators are not directly slashed but should redelegate away from jailed/tombstoned validators — their share of rewards stops the moment the validator leaves the active set.

## Economics

Block reward: **1 SRX per block**, halved every 126M blocks (~4 years at 1s blocks). Premine: 63,000,000 SRX. Hard cap: 315,000,000 SRX. Tokenomics v2 active since mainnet h=640,800 / 2026-04-26 (see [SIP-3](https://github.com/sentrix-labs/SIPs/blob/main/sips/sip-3.md)).

At the 21-active-validator target:
- ~4,114 blocks/day per validator (86,400 ÷ 21)
- ~4,114 SRX/day from rewards at Era 0 (pre-halving)
- Plus tx fee revenue (validator-collected, post-EIP-1559 split per SIP-3)

**51% attack cost:** 11 validators × 15,000 SRX self-stake minimum = 165,000 SRX bond at risk, plus 20% slash on double-sign = 33,000 SRX burned per attacker validator. Total attacker capital exposure: 165K SRX bonded + 33K SRX slashed = 198K SRX minimum, assuming attacker can self-bond the minimum. In practice attackers need vastly more delegated stake to push past honest validators in the top-21 set.

## Gas (EVM execution)

Voyager adds gas metering via revm 38:

| | Value |
|---|---|
| Gas price | 0.1 sentri/gas (post-EIP-1559: base fee + tip) |
| Block gas limit | 30,000,000 |
| Standard transfer | ~21,000 gas = 0.000021 SRX |
| EIP-1559 base-fee burn | Per [SIP-1](https://github.com/sentrix-labs/SIPs/blob/main/sips/sip-1.md) — burned from coinbase, not paid to validator |
