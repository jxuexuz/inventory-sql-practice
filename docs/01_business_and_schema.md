# 业务和表结构

## 业务范围

模拟文具店对4种商品的数量核对。建档后记录实际收货和发货；客户验收合格的退货重新入库，退给供应商的货物减少库存。所有期初数量为0，报表累计统计全部已录入记录，不是任意历史日期的库存快照，也不是可用库存或实物盘点。

入库150支、出库50支、客户退回5支、退给供应商10支，中性笔账面库存为95支。客户退货不回写或扣减原出库数量，否则在公式中再加退货会重复计算。不同计量单位的商品不能直接相加为有业务意义的总库存。

## 五张表

| 表 | 主键 | 关键字段及关联 | 一行的含义 |
| --- | --- | --- | --- |
| products | product_id | product_name、unit | 一个商品档案 |
| stock_in | stock_in_id | product_id关联products；quantity、received_date、remark | 一笔某商品入库记录 |
| stock_out | stock_out_id | product_id关联products；quantity、shipped_date、remark | 一笔某商品出库记录 |
| customer_returns | return_id | stock_out_id关联stock_out；quantity、returned_date、reason | 针对一笔原出库的客户退货 |
| supplier_returns | return_id | stock_in_id关联stock_in；quantity、returned_date、reason | 针对一笔原入库的供应商退货 |

商品名称为VARCHAR(100)，单位为VARCHAR(10)，备注和原因为VARCHAR(200)，日期为DATE，编号及数量为INT。业务编号由模拟数据显式填写，不是自动生成的单据号。交易数量设置NOT NULL和CHECK(quantity > 0)，关联编号设置NOT NULL与外键。

一个商品可以有多笔出入库；一笔出库可以有多笔客户退货，一笔入库也可以有多笔供应商退货。退货表通过原单找商品，不重复存储商品编号。本练习简化为“一笔记录只包含一种商品”，未实现真实订单的单据头和多行明细。

## 报表实现

1. 入库和出库各自按product_id汇总。
2. 客户退货先关联原出库，取得商品编号，再按商品汇总；供应商退货同理关联原入库。
3. 以商品表为主表LEFT JOIN四个汇总结果，保留文件夹和订书机等无交易商品。
4. COALESCE将没有匹配汇总记录产生的NULL转换为0，计算库存。

WITH定义的汇总结果只在当前SQL语句内有效，不创建永久表。先汇总能保证每个商品每侧最多一行，避免入库与出库的多对多组合造成金额或数量膨胀。本项目只核对数量。

## 实施方向的练习对应

这里练习了确认业务口径、建立字段和关联、准备模拟数据、编写报表、核对预期结果以及记录问题。项目没有实际客户需求访谈、ERP参数配置、用户培训或上线验收经历；这些不能写成已完成工作。
