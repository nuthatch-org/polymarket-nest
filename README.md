# polymarket-nest

A [nuthatch](https://github.com/nuthatch-org/nuthatch) nest: **Polymarket on Polygon**.

Conditional Tokens, both CTF exchanges, the NegRisk adapter and the Poly v2 exchange, decoded into
SQL tables on your own machine, with three views over the trades.

One binary, one config file, no graph-node, no gateway, no query fees.

## What it indexes

**Chain:** `polygon`. **5 contracts**, **67 tables**. Addresses are from Polymarket's
[deployment page](https://docs.polymarket.com/developers/CTF/deployment-resources), read on 2026-11-13.

| alias | contract | address |
|---|---|---|
| `ctf` | Conditional Tokens | `0x4d97dcd97ec945f40cf65f87097ace5ea0476045` |
| `exchange` | CTF Exchange | `0xe111180000d2663c0091e4f400237545b87b996b` |
| `neg_risk_exchange` | NegRisk CTF Exchange | `0xe2222d279d744050d28e00520010520000310f59` |
| `neg_risk_adapter` | NegRisk Adapter | `0xd91e80cf2e7be2e162c6513ced06f1dd0da35296` |
| `exchange_v3` | ExchangeV3 Poly v2 (proxy) | `0xe3333700ca9d93003f00f0f71f8515005f6c00aa` |

## Verified

Measured on 2026-11-13 with nuthatch 5.21.0 on an 18-core M5 Pro, against the two keyless public
endpoints in `nuthatch.toml`. One run, not a benchmark.

- `nuthatch dev --backfill 2000 --poll-interval 2s` caught up to the tip at block 97,267,110 with
  **993,419 events in 4 m 40 s** (3,542 events a second). That is about 500 events a block.
- Peak RSS over the run was 326 MB. Disk after it: 37 MB of sealed segments, 33 MB of hot store.
- At the tip, polling every 2 s, 60 samples over two minutes read 0 blocks behind 47 times and never
  more than 3. Neither endpoint rate-limited it while following.
- Checked against a second endpoint: for blocks 97,265,500 to 97,265,529 the nest holds 10,401
  rows across its 67 tables, and `eth_getLogs` for the five addresses on Tenderly's gateway returns
  10,401 logs. `exchange__order_filled` (1,715) and `ctf__transfer_single` (2,317) match one by one.
- `matches` and `fills` agree: 54,785 `OrdersMatched` rows and 54,785 taker-order rows in `fills`
  over blocks 97,264,924 to 97,267,180.
- Three queries over that data, including a top-10 makers by collateral, answered in 46 to 81 ms.
- A restart was back at the tip in under a second.

## What it does not do

- **Full history is not attempted here.** At about 500 events a block, the 93 million blocks since
  Conditional Tokens was deployed are a job for your own archive node, not a public endpoint: both
  public endpoints answered HTTP 429 during a 2,000-block backfill. Pass yours with `--rpc`.
- **No market names.** `token_id` and `conditionId` are the onchain ids. The question text and
  outcomes live in Polymarket's API, not in these contracts.
- **`exchange_v3` is a proxy.** Its current implementation was deployed at block 96,279,044; events
  before that may use an earlier ABI and are not decoded by this nest.
- **Amounts are raw units.** pUSD and the outcome tokens both have 6 decimals; divide by 1e6.
  `tokenId` is a full-width uint256, so use the text column: `tokenId_dec` is NULL.
- 43 of the 67 tables had no rows in the window measured; they are admin and pause events.
- The free drpc endpoint refuses JSON-RPC batches over 10, so `dev` narrows its timestamp batches
  and says so in the log. It works; your own endpoint is quieter.

## Run it

```sh
nuthatch init --from https://github.com/nuthatch-org/polymarket-nest
cd polymarket-nest
nuthatch dev --dir . --backfill 2000 --poll-interval 2s
nuthatch sql --dir . "SELECT venue, count(*) AS trades, sum(collateral) AS pusd_raw FROM matches GROUP BY venue"
```

## Views

- `fills`: one row per `OrderFilled` across the three exchanges. A match emits one row per maker
  order and one for the taker order, whose taker is the exchange itself (`is_taker_order`).
- `matches`: one row per `OrdersMatched`, a taker order and what it filled. Count trades and volume
  here, not in `fills`.
- `volume_hourly`: matched orders and collateral per venue and hour.

The views are one branch per side with no `CASE` over the amounts, so that `sum(collateral)` stays
an exact sum the engine can trace to its column.

```sql
-- the ten makers with the most collateral filled
SELECT maker, count(*) AS fills, sum(collateral) AS pusd_raw
FROM fills WHERE NOT is_taker_order
GROUP BY maker ORDER BY pusd_raw DESC LIMIT 10;
```
