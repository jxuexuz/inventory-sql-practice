USE inventory_portfolio_demo;
-- 示例A：这里显示真假值，不是按数量过滤。笔记本30>40为0。
SELECT stock_in_id, quantity, quantity > 40 AS is_over_40
FROM stock_in WHERE product_id = 2;

-- 示例B：WHERE筛选明细，只保留数量100和50的两行。
SELECT stock_in_id, product_id, quantity
FROM stock_in WHERE quantity > 40 ORDER BY stock_in_id;

-- 示例C：WHERE先过滤明细；结果是商品1数量100，而非150。
SELECT product_id, SUM(quantity) AS total_in
FROM stock_in WHERE quantity > 60 GROUP BY product_id ORDER BY product_id;

-- 示例D：HAVING筛选分组；结果是商品1数量150。
SELECT product_id, SUM(quantity) AS total_in
FROM stock_in GROUP BY product_id HAVING SUM(quantity) > 120 ORDER BY product_id;

-- 错误业务算法演示（SQL语法合法）：2笔入库×2笔出库产生4行，结果300/100。
-- 不可用作库存报表。正确算法见03_inventory_report.sql，真实入库/出库为150/50。
SELECT i.product_id, SUM(i.quantity) AS inflated_in, SUM(o.quantity) AS inflated_out
FROM stock_in AS i INNER JOIN stock_out AS o ON i.product_id = o.product_id
WHERE i.product_id = 1 GROUP BY i.product_id;
