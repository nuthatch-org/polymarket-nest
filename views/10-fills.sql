-- One row per OrderFilled across the three exchanges. A match emits one row per maker order and
-- one for the taker order, whose taker is the exchange itself (is_taker_order). A buy pays
-- collateral (makerAmountFilled) for shares; a sell is the reverse. Raw units: pUSD and outcome
-- tokens both have 6 decimals. One branch per side, with no CASE over the amounts, so that
-- sum(collateral) stays an exact sum the engine can trace to its column.
CREATE VIEW fills AS
  SELECT 'exchange' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "orderHash" AS order_hash, maker, taker, 'buy' AS side, "tokenId" AS token_id,
         "makerAmountFilled_dec" AS collateral, "takerAmountFilled_dec" AS shares, "fee_dec" AS fee, taker = address AS is_taker_order
  FROM "exchange__order_filled" WHERE side = '0'
  UNION ALL
  SELECT 'exchange' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "orderHash" AS order_hash, maker, taker, 'sell' AS side, "tokenId" AS token_id,
         "takerAmountFilled_dec" AS collateral, "makerAmountFilled_dec" AS shares, "fee_dec" AS fee, taker = address AS is_taker_order
  FROM "exchange__order_filled" WHERE side = '1'
  UNION ALL
  SELECT 'neg_risk_exchange' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "orderHash" AS order_hash, maker, taker, 'buy' AS side, "tokenId" AS token_id,
         "makerAmountFilled_dec" AS collateral, "takerAmountFilled_dec" AS shares, "fee_dec" AS fee, taker = address AS is_taker_order
  FROM "neg_risk_exchange__order_filled" WHERE side = '0'
  UNION ALL
  SELECT 'neg_risk_exchange' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "orderHash" AS order_hash, maker, taker, 'sell' AS side, "tokenId" AS token_id,
         "takerAmountFilled_dec" AS collateral, "makerAmountFilled_dec" AS shares, "fee_dec" AS fee, taker = address AS is_taker_order
  FROM "neg_risk_exchange__order_filled" WHERE side = '1'
  UNION ALL
  SELECT 'exchange_v3' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "orderHash" AS order_hash, maker, taker, 'buy' AS side, "tokenId" AS token_id,
         "makerAmountFilled_dec" AS collateral, "takerAmountFilled_dec" AS shares, "fee_dec" AS fee, taker = address AS is_taker_order
  FROM "exchange_v3__order_filled" WHERE side = '0'
  UNION ALL
  SELECT 'exchange_v3' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "orderHash" AS order_hash, maker, taker, 'sell' AS side, "tokenId" AS token_id,
         "takerAmountFilled_dec" AS collateral, "makerAmountFilled_dec" AS shares, "fee_dec" AS fee, taker = address AS is_taker_order
  FROM "exchange_v3__order_filled" WHERE side = '1'
;
