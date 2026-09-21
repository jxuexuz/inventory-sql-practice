USE inventory_portfolio_demo;
-- 先按商品分别汇总，再关联，避免多个明细表互相放大行数。
WITH in_summary AS (
    SELECT product_id, SUM(quantity) AS total_in
    FROM stock_in GROUP BY product_id
), out_summary AS (
    SELECT product_id, SUM(quantity) AS total_out
    FROM stock_out GROUP BY product_id
), return_summary AS (
    SELECT o.product_id, SUM(r.quantity) AS total_return
    FROM customer_returns AS r
    INNER JOIN stock_out AS o ON r.stock_out_id = o.stock_out_id
    GROUP BY o.product_id
), supplier_return_summary AS (
    SELECT i.product_id, SUM(r.quantity) AS total_supplier_return
    FROM supplier_returns AS r
    INNER JOIN stock_in AS i ON r.stock_in_id = i.stock_in_id
    GROUP BY i.product_id
)
SELECT p.product_id, p.product_name, p.unit,
       COALESCE(i.total_in, 0) AS total_in,
       COALESCE(o.total_out, 0) AS total_out,
       COALESCE(r.total_return, 0) AS total_return,
       COALESCE(sr.total_supplier_return, 0) AS total_supplier_return,
       COALESCE(i.total_in, 0) - COALESCE(o.total_out, 0)
       + COALESCE(r.total_return, 0) - COALESCE(sr.total_supplier_return, 0) AS current_stock
FROM products AS p
LEFT JOIN in_summary AS i ON p.product_id = i.product_id
LEFT JOIN out_summary AS o ON p.product_id = o.product_id
LEFT JOIN return_summary AS r ON p.product_id = r.product_id
LEFT JOIN supplier_return_summary AS sr ON p.product_id = sr.product_id
ORDER BY p.product_id;
