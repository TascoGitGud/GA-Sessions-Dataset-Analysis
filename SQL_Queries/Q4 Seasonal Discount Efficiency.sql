WITH
  combined_sales_info AS( -- combine all the necessary information for calculating discount cost
    SELECT
      detail.ProductID,
      product.ProductSubcategoryID,
      subcate.Name subcate_name,
      header.OrderDate order_date,
      detail.OrderQty order_qnt,
      detail.UnitPrice unit_price,
      detail.SpecialOfferID,
      offer.DiscountPct discount_pct,
      offer.Type discount_type
    FROM `adventureworks2019.Sales.SalesOrderDetail` detail
    INNER JOIN `adventureworks2019.Sales.SalesOrderHeader` header -- join order date
      ON detail.SalesOrderID = header.SalesOrderID
    INNER JOIN `adventureworks2019.Sales.SpecialOffer` offer -- joint discount pct and type
      ON detail.SpecialOfferID = offer.SpecialOfferID
    INNER JOIN `adventureworks2019.Production.Product` product -- join subcategory id
      ON detail.ProductID = product.ProductID
    INNER JOIN `adventureworks2019.Production.ProductSubcategory` subcate -- join subcategory name
      ON CAST(product.ProductSubcategoryID AS INT64) = subcate.ProductSubcategoryID
  ),

  calculated_discount_cost AS( -- calculate discount cost 
    SELECT
      EXTRACT(YEAR FROM order_date) year,
      subcate_name,
      (discount_pct * unit_price * order_qnt) discount_cost
    FROM combined_sales_info
    WHERE discount_type = 'Seasonal Discount'
  )

SELECT -- result
  year,
  subcate_name,
  SUM(discount_cost) total_cost
FROM calculated_discount_cost
GROUP BY year,subcate_name
ORDER BY year
