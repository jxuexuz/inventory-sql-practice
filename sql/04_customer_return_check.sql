USE inventory_portfolio_demo;
-- 只检测同一笔出库的累计退货超量；不阻止写入，也不是所有异常的检查。
WITH return_by_shipment AS (
    SELECT stock_out_id, SUM(quantity) AS total_returned
    FROM customer_returns GROUP BY stock_out_id
)
SELECT o.stock_out_id, p.product_name, p.unit,
       o.quantity AS shipped_quantity,
       COALESCE(r.total_returned, 0) AS total_returned,
       o.quantity - COALESCE(r.total_returned, 0) AS remaining_returnable
FROM stock_out AS o
INNER JOIN products AS p ON o.product_id = p.product_id
LEFT JOIN return_by_shipment AS r ON o.stock_out_id = r.stock_out_id
WHERE COALESCE(r.total_returned, 0) > o.quantity
ORDER BY o.stock_out_id;
