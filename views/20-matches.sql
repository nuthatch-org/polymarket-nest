-- One row per OrdersMatched: a taker order and what it filled, from the taker's side.
-- Count trades and volume here, not in fills, which carries both sides of each match.
CREATE VIEW matches AS
  SELECT 'exchange' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "takerOrderHash" AS taker_order_hash, "takerOrderMaker" AS taker, 'buy' AS side,
         "tokenId" AS token_id, "makerAmountFilled_dec" AS collateral, "takerAmountFilled_dec" AS shares
  FROM "exchange__orders_matched" WHERE side = '0'
  UNION ALL
  SELECT 'exchange' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "takerOrderHash" AS taker_order_hash, "takerOrderMaker" AS taker, 'sell' AS side,
         "tokenId" AS token_id, "takerAmountFilled_dec" AS collateral, "makerAmountFilled_dec" AS shares
  FROM "exchange__orders_matched" WHERE side = '1'
  UNION ALL
  SELECT 'neg_risk_exchange' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "takerOrderHash" AS taker_order_hash, "takerOrderMaker" AS taker, 'buy' AS side,
         "tokenId" AS token_id, "makerAmountFilled_dec" AS collateral, "takerAmountFilled_dec" AS shares
  FROM "neg_risk_exchange__orders_matched" WHERE side = '0'
  UNION ALL
  SELECT 'neg_risk_exchange' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "takerOrderHash" AS taker_order_hash, "takerOrderMaker" AS taker, 'sell' AS side,
         "tokenId" AS token_id, "takerAmountFilled_dec" AS collateral, "makerAmountFilled_dec" AS shares
  FROM "neg_risk_exchange__orders_matched" WHERE side = '1'
  UNION ALL
  SELECT 'exchange_v3' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "takerOrderHash" AS taker_order_hash, "takerOrderMaker" AS taker, 'buy' AS side,
         "tokenId" AS token_id, "makerAmountFilled_dec" AS collateral, "takerAmountFilled_dec" AS shares
  FROM "exchange_v3__orders_matched" WHERE side = '0'
  UNION ALL
  SELECT 'exchange_v3' AS venue, block_number, block_timestamp, tx_hash, log_index,
         "takerOrderHash" AS taker_order_hash, "takerOrderMaker" AS taker, 'sell' AS side,
         "tokenId" AS token_id, "takerAmountFilled_dec" AS collateral, "makerAmountFilled_dec" AS shares
  FROM "exchange_v3__orders_matched" WHERE side = '1'
;
