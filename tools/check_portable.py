"""SQLite内存逻辑回归；不连接MySQL，不替代MySQL验收。Python 3标准库。"""
from pathlib import Path
import re
import sqlite3

ROOT = Path(__file__).resolve().parents[1]


def statements(name):
    text = (ROOT / 'sql' / name).read_text(encoding='utf-8')
    text = re.sub(r'--[^\n]*', '', text)
    text = re.sub(r'CREATE DATABASE[^;]*;', '', text, flags=re.I)
    text = re.sub(r'USE\s+inventory_portfolio_demo\s*;', '', text, flags=re.I)
    text = re.sub(r'START TRANSACTION', 'BEGIN TRANSACTION', text, flags=re.I)
    return [s.strip() for s in text.split(';') if s.strip()]


def execute_file(db, name):
    result = []
    for statement in statements(name):
        result.append(db.execute(statement).fetchall())
    return result


def expect(label, actual, expected):
    if actual != expected:
        raise AssertionError(f'{label}: {actual!r} != {expected!r}')
    print(f'PASS {label}')


def main():
    db = sqlite3.connect(':memory:')
    db.execute('PRAGMA foreign_keys = ON')
    execute_file(db, '01_schema.sql')
    execute_file(db, '02_seed.sql')
    tables = ('products', 'stock_in', 'stock_out', 'customer_returns', 'supplier_returns')
    counts = [db.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0] for t in tables]
    expect('seed counts', counts, [4, 3, 3, 2, 2])
    expected_report = [
        (1, '中性笔', '支', 150, 50, 5, 10, 95),
        (2, '笔记本', '本', 30, 8, 2, 4, 20),
        (3, '文件夹', '个', 0, 0, 0, 0, 0),
        (4, '订书机', '台', 0, 0, 0, 0, 0),
    ]
    expect('inventory four rows', execute_file(db, '03_inventory_report.sql')[-1], expected_report)
    expect('current returns no excess', execute_file(db, '04_customer_return_check.sql')[-1], [])
    expect('four boundary cases select only excess', execute_file(db, '05_boundary_tests.sql')[-1],
           [('累计退货超量', 30, 35, 5)])
    expected_examples = [[(3, 30, 0)], [(1, 1, 100), (2, 1, 50)], [(1, 100)], [(1, 150)], [(1, 300, 100)]]
    expect('learning comparisons', execute_file(db, '06_learning_comparisons.sql'), expected_examples)

    # 整理阶段补充：同一笔出库已有5支退货，再退26支应检测出累计31支。
    db.execute('SAVEPOINT extra_return')
    db.execute("INSERT INTO customer_returns VALUES (99, 1, 26, '2026-09-20', '仅内存测试')")
    expect('multiple returns aggregated', execute_file(db, '04_customer_return_check.sql')[-1],
           [(1, '中性笔', '支', 30, 31, -1)])
    db.execute('ROLLBACK TO extra_return')
    db.execute('RELEASE extra_return')

    # 这些约束检查仅说明SQLite适配模型行为；MySQL需在目标版本中另外验收。
    invalid = {
        'duplicate primary key': "INSERT INTO products VALUES (1, '重复', '支')",
        'missing parent product': "INSERT INTO stock_in VALUES (99, 999, 1, '2026-09-20', '')",
        'missing parent shipment': "INSERT INTO customer_returns VALUES (99, 999, 1, '2026-09-20', '')",
        'missing parent receipt': "INSERT INTO supplier_returns VALUES (99, 999, 1, '2026-09-20', '')",
        'zero quantity': "INSERT INTO stock_out VALUES (99, 1, 0, '2026-09-20', '')",
        'negative quantity': "INSERT INTO customer_returns VALUES (99, 1, -1, '2026-09-20', '')",
    }
    for label, statement in invalid.items():
        db.execute('SAVEPOINT invalid_case')
        try:
            db.execute(statement)
        except sqlite3.IntegrityError:
            print(f'PASS constraint {label}')
        else:
            raise AssertionError(f'Expected rejection: {label}')
        finally:
            db.execute('ROLLBACK TO invalid_case')
            db.execute('RELEASE invalid_case')
    expect('test fixtures leave report unchanged', execute_file(db, '03_inventory_report.sql')[-1], expected_report)
    db.close()
    print('All portable checks passed. MySQL reproduction remains a separate acceptance step.')


if __name__ == '__main__':
    main()
