CREATE DATABASE retail;
use retail;
drop table df_orders;
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),  -- No space
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),  -- No space
    profit DECIMAL(7,2)
);
select * from df_orders;

-- find top 10 highest revenue generating products
SELECT product_id, SUM(sale_price) as sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- find top 5 highest selling products in each region

WITH RANK_PRODUCTS AS (
SELECT region,product_id, SUM(sale_price) as sales,
ROW_NUMBER() OVER(PARTITION BY REGION ORDER BY SUM(sale_price) DESC) AS rnk
FROM df_orders
GROUP BY product_id,region)
SELECT region, product_id,sales,rnk
FROM RANK_PRODUCTS
WHERE rnk<=5
ORDER BY region,rnk;

-- Find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
With mon_growth as (
select year(order_date) as order_year,
month(order_date) as order_month,SUM(sale_price) as sales
from df_orders
GROUP BY year(order_date),
month(order_date))
SELECT order_month,
SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END)AS sales_2023
from mon_growth
GROUP BY order_month
ORDER BY order_month;

-- for each category which month had highest sales

WITH highest_category AS (
SELECT category, 
DATE_FORMAT(order_date,'%Y-%m') as order_year_month,
SUM(sale_price) AS sales,
ROW_NUMBER() OVER(PARTITION BY CATEGORY) AS rn 
FROM df_orders
GROUP BY category,DATE_FORMAT(order_date,'%Y-%m') 
ORDER BY category,DATE_FORMAT(order_date,'%Y-%m'))
SELECT *
FROM highest_category
WHERE rn=1;

--  which sub category had highest growth by profit %in 2023 compare to 2022
With profit_growth as (
SELECT sub_category,year(order_date) as order_year,
SUM(sale_price) as sales
from df_orders
GROUP BY sub_category,year(order_date)),
profit_growth1 AS (SELECT sub_category,
SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END)AS sales_2023
from profit_growth
GROUP BY sub_category
ORDER BY sub_category)
SELECT *,(sales_2023-sales_2022)*100/sales_2022
FROM profit_growth1
ORDER BY (sales_2023-sales_2022)*100/sales_2022 DESC
LIMIT 1
;

--  which sub category had highest growth by profit in 2023 compare to 2022
With profit_growth as (
SELECT sub_category,year(order_date) as order_year,
SUM(sale_price) as sales
from df_orders
GROUP BY sub_category,year(order_date)),
profit_growth1 AS (SELECT sub_category,
SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END)AS sales_2023
from profit_growth
GROUP BY sub_category
ORDER BY sub_category)
SELECT *,(sales_2023-sales_2022)
FROM profit_growth1
ORDER BY (sales_2023-sales_2022) DESC
LIMIT 1
;

