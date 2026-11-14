-- Matched taker orders and collateral per venue and hour. Collateral is raw pUSD units (6 decimals).
CREATE VIEW volume_hourly AS
  SELECT venue,
         block_timestamp - (block_timestamp % 3600) AS hour,
         count(*) AS matches,
         sum(collateral) AS collateral
  FROM matches
  GROUP BY venue, block_timestamp - (block_timestamp % 3600);
