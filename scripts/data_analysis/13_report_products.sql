/*
================================================================================
Product Report
================================================================================
Purpose:
	- This report consolidates key product metrics and behaviors.

Highlights: 
	1. Gathers essential fields such as product name, category, subcategory, and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		- Total Orders
		- Total Sales
		- Total Quantity Sold
		- Total Customers (unique)
		- Lifespan (in months)
	4. Calculates Valuable KPIs:
		- Recency (months since last sale)
		- Average Order Revenue (AOR)
		- Average Monthly Revenue
================================================================================
*/
DROP VIEW IF EXISTS gold.report_products;
CREATE VIEW gold.report_products AS
WITH base_query AS (
/* ----------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------- */
	SELECT
		f.order_number,
		f.order_date,
		f.customer_key,
		f.sales,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.product_cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
	WHERE f.order_date IS NOT NULL
)
, product_aggregations AS (
/* ----------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------- */
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		product_cost,
		EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan,
		MAX(order_date) AS last_order_date,
		COUNT(order_number) AS total_orders,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(sales) AS total_sales,
		SUM(quantity) AS total_quantity,
		ROUND((SUM(sales)::NUMERIC / NULLIF(SUM(quantity), 0)), 2) AS avg_selling_price
	FROM base_query
	GROUP BY
		product_key,
		product_name,
		category,
		subcategory,
		product_cost
)
/* ----------------------------------------------------------------------
3) Final Query: Combines all product results into one output
---------------------------------------------------------------------- */
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	product_cost,
	last_order_date,
	EXTRACT(YEAR FROM AGE('2014-02-09'::DATE, last_order_date)) * 12 + EXTRACT(MONTH FROM AGE('2014-02-09'::DATE, last_order_date)) AS recency,
	lifespan,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	total_orders,
	total_quantity,
	total_customers,
	total_sales,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE
		WHEN total_orders = 0 THEN 0 -- Catches any orders of $0
		ELSE ROUND(total_sales::NUMERIC / total_orders, 2)
	END AS avg_order_revenue,
	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN ROUND(total_sales, 2)
		ELSE ROUND(total_sales / lifespan, 2)
	END AS avg_monthly_revenue
FROM product_aggregations;
