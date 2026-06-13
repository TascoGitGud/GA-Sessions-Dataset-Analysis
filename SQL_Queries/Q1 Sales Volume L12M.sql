WITH
  sales_order_with_date AS( -- join Order Date 
    SELECT
      sales_detail.SalesOrderID,
      sales_detail.ProductID,
      sales_detail.OrderQty,
      sales_detail.LineTotal,
      DATE(sales_header.OrderDate) as order_date,
      MAX(DATE(sales_header.OrderDate)) OVER() AS last_order_date,
      DATE_SUB(MAX(DATE(sales_header.OrderDate)) OVER(), INTERVAL 12 MONTH) L12M --L12M
    FROM `adventureworks2019.Sales.SalesOrderDetail` sales_detail
    INNER JOIN `adventureworks2019.Sales.SalesOrderHeader` sales_header
    ON sales_detail.SalesOrderID = sales_header.SalesOrderID
  ),

  sales_in_L12M AS( -- join SubCategory 
    SELECT
      s.SalesOrderID,
      s.OrderQty,	
      s.LineTotal,	
      FORMAT_DATE('%b %Y', s.order_date) period, --format date
      p.ProductSubcategoryID,
      sub.name AS product_subcategory
    FROM sales_order_with_date s
    LEFT JOIN `adventureworks2019.Production.Product` p
    ON s.ProductID = p.ProductID
    LEFT JOIN `adventureworks2019.Production.ProductSubcategory` sub
    ON CAST(p.ProductSubcategoryID AS INT64) = sub.ProductSubcategoryID
    WHERE order_date >= L12M
  )

SELECT -- final output
  period,
  product_subcategory, 
  SUM(OrderQty) AS qty_item,
  ROUND(SUM(LineTotal), 4) as total_sales,
  COUNT(SalesOrderID) AS oder_cnt
FROM sales_in_L12M
GROUP BY period, product_subcategory
order by period desc, product_subcategory
