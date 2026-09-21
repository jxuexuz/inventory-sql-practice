-- 仅在新建且为空的演示库中运行一次。遇错停止并执行 ROLLBACK，不要继续 COMMIT。
USE inventory_portfolio_demo;
SELECT DATABASE();
START TRANSACTION;
INSERT INTO products (product_id, product_name, unit) VALUES
(1, '中性笔', '支'), (2, '笔记本', '本'), (3, '文件夹', '个'), (4, '订书机', '台');
INSERT INTO stock_in (stock_in_id, product_id, quantity, received_date, remark) VALUES
(1, 1, 100, '2026-09-09', '中性笔到货第一批'),
(2, 1, 50, '2026-09-09', '中性笔到货第二批'),
(3, 2, 30, '2026-09-09', '笔记本到货第一批');
INSERT INTO stock_out (stock_out_id, product_id, quantity, shipped_date, remark) VALUES
(1, 1, 30, '2026-09-12', '中性笔第一笔销售出库'),
(2, 1, 20, '2026-09-12', '中性笔第二笔销售出库'),
(3, 2, 8, '2026-09-12', '笔记本第一笔销售出库');
INSERT INTO customer_returns (return_id, stock_out_id, quantity, returned_date, reason) VALUES
(1, 1, 5, '2026-09-15', '客户多购，退回商品验收合格'),
(2, 3, 2, '2026-09-15', '多购，商品完好');
INSERT INTO supplier_returns (return_id, stock_in_id, quantity, returned_date, reason) VALUES
(1, 1, 10, '2026-09-17', '协商退回多采购商品'),
(2, 3, 4, '2026-09-17', '协商退回多采购商品');
COMMIT;

SELECT 'products' AS table_name, COUNT(*) AS row_count
FROM inventory_portfolio_demo.products
UNION ALL
SELECT 'stock_in', COUNT(*)
FROM inventory_portfolio_demo.stock_in
UNION ALL
SELECT 'stock_out', COUNT(*)
FROM inventory_portfolio_demo.stock_out
UNION ALL
SELECT 'customer_returns', COUNT(*)
FROM inventory_portfolio_demo.customer_returns
UNION ALL
SELECT 'supplier_returns', COUNT(*)
FROM inventory_portfolio_demo.supplier_returns;
