USE inventory_portfolio_demo;
-- 只生成内存查询结果，不插入异常数据。预期仅返回超量案例，超量为5。
WITH test_cases AS (
    SELECT '正常退货' AS case_name, 30 AS shipped_quantity, 5 AS total_returned
    UNION ALL SELECT '恰好全部退回', 30, 30
    UNION ALL SELECT '累计退货超量', 30, 35
    UNION ALL SELECT '尚未退货', 20, 0
)
SELECT case_name, shipped_quantity, total_returned,
       total_returned - shipped_quantity AS excess_quantity
FROM test_cases
WHERE total_returned > shipped_quantity;
