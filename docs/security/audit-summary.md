# Sentrix Security Audit Summary

**Last updated:** 2026-04-28

This document is the navigation hub for security material on Sentrix Chain. It is intended for:
- External auditors performing diligence
- Listing platforms (CG, CMC, exchanges)
- Researchers reviewing the chain's security posture
- Future contributors picking up the codebase cold

For technical detail, see the dedicated documents:

- [`security-audit-v11.md`](security-audit-v11.md) — most recent code review (39 files, ~6,500 LoC)
- [`security-report.md`](security-report.md) — earlier cumulative summary
- [`pentest-results.md`](pentest-results.md) — penetration test methodology + raw results
- [`attack-vectors.md`](attack-vectors.md) — threat model
- [`multisig.md`](multisig.md) — SentrixSafe technical specification

## Specialized audits

In addition to the numbered code-review rounds, several topical audits have been run:

| Topic | Date | Status |
|---|---|---|
| BFT consensus engine | 2026-04-20 | Reviewed; bugs found + fixed (BFT skip-round, justification-set divergence) |
| EVM integration & gas accounting | 2026-04-22 | Reviewed; reverted-tx state-leak bug fixed (PR #281), gas-cap EIP-7825 alignment fixed (v2.1.46) |
| Dependency supply chain | 2026-04-21 | `cargo audit` clean; CI runs `cargo audit` + `gitleaks` on every PR |
| CI/cd security posture | 2026-04-21 | Reviewed; secret-scanning + signed-commit verification active |
| Validator infrastructure security | 2026-04-21 | Reviewed; SSH-key custody, validator host hardening documented in operator runbooks |
| Tokenomics correctness | 2026-04-25 | Reviewed; supply invariants hold across all forks |
| BFT skip-round root cause | 2026-04-28 | Phase 2 RCA documented in operator runbooks |

## External audit posture

No third-party audit firm has reviewed Sentrix Chain code as of 2026-04-28. External audit is something we'd pursue when budget + scope align — no committed timeline.

The chain runs continuous internal review:
- `cargo audit` + `gitleaks` on every PR
- `slither` + `mythril` on Solidity contracts (CI gate)
- Manual code review by the internal Sentrix Labs / SentrisCloud security team for every PR
- Public bug bounty: see [security.md](https://github.com/sentrix-labs/sentrix/blob/main/security.md) (safe-harbor policy in effect)

Listing platforms or external auditors performing diligence: contact `security@sentriscloud.com` for code-walkthrough or audit-prep discussion.

## How to report

If you find a security issue:

1. **Do not open a public GitHub issue.**
2. Email `security@sentriscloud.com` with details.
3. Include reproduction steps, impact assessment, and suggested fix if applicable.
4. We acknowledge within 48 hours; remediation timeline depends on severity.
5. Safe-harbor policy applies — researchers acting in good faith are protected from legal action; see [security.md](https://github.com/sentrix-labs/sentrix/blob/main/security.md) for full terms.

## Cross-references

- [`security.md`](https://github.com/sentrix-labs/sentrix/blob/main/security.md) — safe-harbor + reporting policy
- [`security-report.md`](security-report.md) — earlier cumulative summary
- [`security-audit-v11.md`](security-audit-v11.md) — most recent round, full detail
- [`attack-vectors.md`](attack-vectors.md) — threat model
- [`pentest-results.md`](pentest-results.md) — pentest methodology + outcomes
- [`multisig.md`](multisig.md) — SentrixSafe technical specification
- [governance.md](../governance.md) — control / governance model
