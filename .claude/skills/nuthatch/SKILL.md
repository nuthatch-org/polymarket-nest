---
name: nuthatch
description: Query this self-hosted nuthatch nest on polygon - decoded events, and read-only SQL. Use when asked about on-chain activity for these contracts.
---

# Querying the nuthatch nest

Contracts indexed on polygon:
- `ctf` = 0x4d97dcd97ec945f40cf65f87097ace5ea0476045
- `exchange` = 0xe111180000d2663c0091e4f400237545b87b996b
- `neg_risk_exchange` = 0xe2222d279d744050d28e00520010520000310f59
- `neg_risk_adapter` = 0xd91e80cf2e7be2e162c6513ced06f1dd0da35296
- `exchange_v3` = 0xe3333700ca9d93003f00f0f71f8515005f6c00aa

Data is local - never call an external API for it.

## Preferred: MCP
If a `nuthatch` MCP server is configured, use its tools. Call `schema` first to learn the
data model, then `sql` / `entity`.

## Fallback: HTTP (a `nuthatch dev` must be running)
- Recent rows:  `curl localhost:8288/entities?limit=20`
- Read-only SQL: `curl -G localhost:8288/sql --data-urlencode 'q=SELECT count(*) FROM ctf__approval_for_all'`

`sql` reads hot and sealed rows together, so it covers the live tip. Each answer's
`provenance.sealed_through` is the block through which this nest has sealed history; newer rows
may still be hot, and it is not the chain's finality head.
