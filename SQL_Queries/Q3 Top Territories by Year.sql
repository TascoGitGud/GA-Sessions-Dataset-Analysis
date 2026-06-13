WITH 
  territory_vs_order_count AS ( -- calculate order quantity by territory
    SELECT 
      EXTRACT(YEAR FROM OrderDate) yr,
      TerritoryID,
      SUM(OrderQty) order_cnt
    FROM `adventureworks2019.Sales.SalesOrderDetail` sales_detail
    INNER JOIN `adventureworks2019.Sales.SalesOrderHeader` sales_header
      ON sales_detail.SalesOrderID = sales_header.SalesOrderID
    GROUP BY EXTRACT(YEAR FROM OrderDate), TerritoryID
    ORDER BY yr
  ),

  ranking_order_quantity AS( -- ranking
    SELECT
      yr,
      TerritoryID, 
      order_cnt,
      DENSE_RANK() OVER(PARTITION BY yr ORDER BY order_cnt DESC) rk
    FROM territory_vs_order_count
    )

SELECT * -- display top 3
FROM ranking_order_quantity
WHERE rk <= 3
ORDER BY yr DESC
