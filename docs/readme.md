# Sentrix Chain — Docs

## Architecture

- [Overview](architecture/overview.md) — components, module map, data flow
- [Consensus](architecture/consensus.md) — Voyager DPoS+BFT (current); Pioneer PoA round-robin was bootstrap consensus pre-2026-04-25
- [Networking](architecture/networking.md) — libp2p, peer management, sync
- [State](architecture/state.md) — trie, MDBX, state roots, merkle proofs
- [Transactions](architecture/transactions.md) — tx lifecycle, fees, nonce, mempool

## Security

- [Code Audit V11](security/security-audit-v11.md) — source review findings (8.3/10)
- [Attack Vectors](security/attack-vectors.md) — 13 scenarios, risk matrix
- [Pentest Results](security/pentest-results.md) — 6/6 passed
- [Security Report](security/security-report.md) — full report

## Operations

- [Networks](operations/networks.md) — mainnet + testnet config, how to connect
- [Domains](operations/domains.md) — all service URLs and endpoints
- [Deployment](operations/deployment.md) — build, configure, run a node
- [CI/CD](operations/ci-cd.md) — pipeline, deploy phases
- [Validators](operations/validators.md) — setup, registration, current set
- [Monitoring](operations/monitoring.md) — health checks, troubleshooting

## Tokenomics

- [SRX](tokenomics/srx.md) — supply, halving, fees
- [Staking](tokenomics/staking.md) — DPoS design (Voyager, planned)
- [Token Standards](tokenomics/token-standards.md) — SRC-20 native + SRC-20 (EVM); single-token chain (SRX-only)

## Roadmap

- [Pioneer](roadmap/phase1.md) — PoA round-robin (completed h=0…579046, succeeded by Voyager 2026-04-25)
- [Voyager](roadmap/phase2.md) — DPoS + BFT + EVM (planned)
- [Changelog](roadmap/changelog.md) — PR history

## Quick Ref

| | |
|-|-|
| Chain ID | 7119 |
| Block time | 1s |
| Coin | SRX (1 SRX = 100M sentri) |
| Max supply | 315M SRX (post tokenomics-v2 fork; was 210M pre-fork) |
| Reward | 1 SRX/block, halving every 126M blocks (~4 years, BTC parity, post-fork) |
| Fees | 50% burn / 50% validator |
| Consensus | PoA (Pioneer) → DPoS+BFT (Voyager) |
| License | BUSL-1.1 |

## Quick Start

```bash
cargo build --release
cargo test
sentrix wallet generate
sentrix init --admin-address 0x<addr>
SENTRIX_VALIDATOR_KEY=<key> sentrix start --peers [PEER]:30303
# (Or: sentrix start --validator-keystore /path/to/validator.json)
```
