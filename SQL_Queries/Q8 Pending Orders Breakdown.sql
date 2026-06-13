SELECT
  EXTRACT(YEAR FROM header.ModifiedDate) yr,
  Status,
  COUNT(DISTINCT header.PurchaseOrderID) order_cnt,
  SUM(TotalDue) value
FROM `adventureworks2019.Purchasing.PurchaseOrderDetail` detail 
LEFT JOIN `adventureworks2019.Purchasing.PurchaseOrderHeader` header
  ON detail.PurchaseOrderID = header.PurchaseOrderID
WHERE EXTRACT(YEAR FROM header.ModifiedDate) = 2014
  AND Status = 1 
GROUP BY 1,2
