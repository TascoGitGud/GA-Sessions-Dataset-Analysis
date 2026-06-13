WITH
  sales_with_date AS ( -- join sales header and detail 
    SELECT
      sales_detail.SalesOrderID order_id,
      sales_detail.ProductID product_id,
      sales_detail.OrderQty order_qty,
      DATE(sales_header.OrderDate) as order_date,
    FROM `adventureworks2019.Sales.SalesOrderDetail` sales_detail
    INNER JOIN `adventureworks2019.Sales.SalesOrderHeader` sales_header
      ON sales_detail.SalesOrderID = sales_header.SalesOrderID
  ),

  sales_with_date_subcate_name AS ( -- join subcategory name 
    SELECT
      order_id,
      product_id,	
      order_qty,
      EXTRACT(YEAR FROM order_date) order_year,
      p.ProductSubcategoryID product_subcate_id,
      sub.Name subcate_name
    FROM sales_with_date s
    LEFT JOIN `adventureworks2019.Production.Product` p
      ON s.product_id = p.ProductID
    LEFT JOIN `adventureworks2019.Production.ProductSubcategory` sub
      ON CAST(p.ProductSubcategoryID AS INT64) = sub.ProductSubcategoryID
  ),

  qty_sum_by_subcate AS( -- calculate quantity by subcategory and year
  SELECT 
    order_year,
    subcate_name, 
    SUM(order_qty) qty_item,
  FROM sales_with_date_subcate_name
  GROUP BY subcate_name, order_year
  ORDER BY order_year,subcate_name
  ),

qty_growth AS( -- calculate YoY rate and rank
  SELECT
    a.order_year,
    a.subcate_name,	
    a.qty_item,
    b.order_year prev_year,
    b.qty_item prev_qty_item,
    ROUND((a.qty_item/b.qty_item - 1), 2) qty_diff,
    DENSE_RANK() OVER(ORDER BY ROUND((a.qty_item/b.qty_item - 1), 2) DESC) as growth_rank
  FROM qty_sum_by_subcate a
  LEFT JOIN qty_sum_by_subcate b
    ON a.subcate_name = b.subcate_name
      AND a.order_year = b.order_year + 1
  ORDER BY order_year, subcate_name
 )

SELECT --filter 
  subcate_name Name,
  qty_item,
  prev_qty_item prv_qty,
  qty_diff
FROM qty_growth
WHERE growth_rank <= 3 --top 3
ORDER BY qty_diff DESC
