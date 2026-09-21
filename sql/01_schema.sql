-- 首次初始化使用新数据库。若库已存在，请停止，不要忽略错误继续执行。
-- 不含 DROP 或清空操作，不操作原 inventory_practice 库。
SHOW DATABASES LIKE 'inventory_portfolio_demo';
CREATE DATABASE inventory_portfolio_demo CHARACTER SET utf8mb4;
USE inventory_portfolio_demo;
SELECT DATABASE();

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    unit VARCHAR(10) NOT NULL
);
CREATE TABLE stock_in (
    stock_in_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    received_date DATE NOT NULL,
    remark VARCHAR(200),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    CHECK (quantity > 0)
);
CREATE TABLE stock_out (
    stock_out_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    shipped_date DATE NOT NULL,
    remark VARCHAR(200),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    CHECK (quantity > 0)
);
CREATE TABLE customer_returns (
    return_id INT PRIMARY KEY,
    stock_out_id INT NOT NULL,
    quantity INT NOT NULL,
    returned_date DATE NOT NULL,
    reason VARCHAR(200),
    FOREIGN KEY (stock_out_id) REFERENCES stock_out(stock_out_id),
    CHECK (quantity > 0)
);
CREATE TABLE supplier_returns (
    return_id INT PRIMARY KEY,
    stock_in_id INT NOT NULL,
    quantity INT NOT NULL,
    returned_date DATE NOT NULL,
    reason VARCHAR(200),
    FOREIGN KEY (stock_in_id) REFERENCES stock_in(stock_in_id),
    CHECK (quantity > 0)
);

SHOW TABLES FROM inventory_portfolio_demo;