WITH 
  successful_order AS ( -- find completed order 
    SELECT  
      EXTRACT(MONTH FROM ModifiedDate) order_month,
      CustomerID customer_id
    FROM `adventureworks2019.Sales.SalesOrderHeader` 
    WHERE EXTRACT(YEAR FROM ModifiedDate) = 2014
      AND Status = 5
    ORDER BY customer_id, order_month
  ),

  rank_time_order AS ( -- find order time by customer_id
    SELECT
      *,
      ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_month) order_time
    FROM successful_order
  ),

  first_order AS ( -- find first order
    SELECT 
      order_month AS month_join, 
      customer_id
    FROM rank_time_order
    WHERE order_time = 1
  ),

  find_month_diff AS ( -- join first order and successful order to find month difference
    SELECT
      distinct order_month,
      month_join,
      a.customer_id,
      (order_month - month_join) month_diff_num
    FROM successful_order a
    INNER JOIN first_order b
      ON a.customer_id = b.customer_id
    ORDER BY month_join, order_month
  )

SELECT -- find month difference and count customer number
  month_join,
  CONCAT('M-',month_diff_num) month_diff,
  COUNT(customer_id) customer_count
FROM find_month_diff
GROUP BY month_join, CONCAT('M-',month_diff_num)
ORDER BY month_join, month_diff
