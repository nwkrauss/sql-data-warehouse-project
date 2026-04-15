/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the Total Sales
SELECT
	TO_CHAR(SUM(sales), '$999,999,999') AS total_sales
FROM gold.fact_sales;
-- Find how many items are sold
SELECT
	TO_CHAR(SUM(quantity), '999,999') AS total_items_sold
FROM gold.fact_sales;
-- Find the average selling price
SELECT
	TO_CHAR(AVG(price), '$999,999.99') AS average_price
FROM gold.fact_sales;
-- Find the Total number of Orders
SELECT
	COUNT(*) AS total_orders,
	COUNT(DISTINCT order_number) AS total_dist_orders
FROM gold.fact_sales;
-- Find the total number of products
SELECT COUNT(product_name) AS total_products FROM gold.dim_products
-- Find the total number of customers
SELECT
	TO_CHAR(COUNT(customer_key), '999,999') AS total_number_customers
FROM gold.dim_customers;
-- Find the total number of customers that have placed an order
SELECT
	TO_CHAR(COUNT(DISTINCT customer_key), '999,999') AS total_number_customers
FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of the business
-- >> I wrapped it in a subquery to add 'priority' column for ordering while keeping it hidden
SELECT measure_name, measure_value
FROM (
	SELECT 'Total Sales' AS measure_name, TO_CHAR(SUM(sales), '$99,999,999') AS measure_value, 1 AS priority FROM gold.fact_sales
	UNION ALL
	SELECT 'Total Quantity', TO_CHAR(SUM(quantity), '999,999'), 2 FROM gold.fact_sales
	UNION ALL
	SELECT 'Average Price', TO_CHAR(AVG(price), '$999.99'), 3 FROM gold.fact_sales
	UNION ALL
	SELECT 'Total Number of Orders', TO_CHAR(COUNT(DISTINCT order_number), '999,999'), 4 FROM gold.fact_sales
	UNION ALL
	SELECT 'Total Number of Products', TO_CHAR(COUNT(DISTINCT product_name), '999,999'), 5 FROM gold.dim_products
	UNION ALL
	SELECT 'Total Number of Customers', TO_CHAR(COUNT(DISTINCT customer_id), '999,999'), 6 FROM gold.dim_customers
) as report_subquery
ORDER BY priority;
