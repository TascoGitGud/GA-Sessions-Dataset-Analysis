WITH 
  sales_2011 AS( -- joinning tables to find sales infors in 2011
    SELECT 
      EXTRACT (MONTH FROM OrderDate) mth,
      EXTRACT (year FROM OrderDate) yr,
      detail.ProductID,
      p.Name,
      SUM(OrderQty) sales
    FROM `adventureworks2019.Sales.SalesOrderDetail` detail
    INNER JOIN `adventureworks2019.Sales.SalesOrderHeader` header
      ON detail.SalesOrderID = header.SalesOrderID
    INNER JOIN `adventureworks2019.Production.Product` p
      ON detail.ProductID = p.ProductID
    WHERE EXTRACT (year FROM OrderDate) = 2011
    GROUP BY 1, 2, 3, 4
    ORDER BY 1 DESC, sales
  ),

  stock_2011 AS ( -- joinning tables to find stock infors in 2011
    SELECT 
      EXTRACT(MONTH FROM o.ModifiedDate) mth,
      EXTRACT(YEAR FROM o.ModifiedDate) yr,
      o.ProductID,
      p.Name product_name,
      SUM(StockedQty) stock
    FROM `adventureworks2019.Production.WorkOrder` o
    INNER JOIN `adventureworks2019.Production.Product` p
      ON o.ProductID = p.ProductID
    WHERE EXTRACT(YEAR FROM o.ModifiedDate) = 2011 
    GROUP BY 1,2,3,4
    ORDER BY 1 DESC)

SELECT -- combined CTE 
  sa.mth,
  sa.yr,
  sa.ProductId,
  sa.Name,
  sales,
  stock,
  ROUND((stock/sales), 1) ratio  -- calculating the stock-to-sales ratio
FROM sales_2011 sa
LEFT JOIN stock_2011 st
  ON sa.mth = st.mth   
  AND sa.productID = st.productID
ORDER BY 1 DESC, 7 DESC
