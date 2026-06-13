WITH raw_data AS (
  SELECT
    EXTRACT(MONTH FROM a.ModifiedDate) mth,
    EXTRACT(YEAR FROM a.ModifiedDate) yr,
    b.Name,
    SUM(StockedQty) stock_qty
  FROM `adventureworks2019.Production.WorkOrder` a
  LEFT JOIN `adventureworks2019.Production.Product` b 
    ON a.ProductID = b.ProductID
  WHERE FORMAT_TIMESTAMP("%Y", a.ModifiedDate) = '2011'
  GROUP BY 1, 2, 3
)

SELECT
  Name,
  mth,
  yr,
  stock_qty,
  stock_prv,
  ROUND(COALESCE((stock_qty / stock_prv - 1) * 100, 0), 1) diff
FROM (
  SELECT 
    *,
    LEAD(stock_qty) OVER (PARTITION BY Name ORDER BY mth DESC) stock_prv
  FROM raw_data
)
ORDER BY Name ASC, mth DESC