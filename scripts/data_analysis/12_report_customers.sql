/*
================================================================================
Customer Report
================================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors.

Highlights: 
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- Total Orders
		- Total Sales
		- Total Quantity Purchased
		- Total Products
		- Lifespan (in months)
	4. Calculates Valuable KPIs:
		- Recency (months since last order)
		- Average Order Value
		- Average Monthly Spend
================================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
DROP VIEW IF EXISTS gold.report_customers;
CREATE VIEW gold.report_customers AS
WITH base_query AS(
/* ----------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------- */
	SELECT
		f.order_number,
		f.product_key,
		f.order_date,
		f.quantity,
		f.sales,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ',c.last_name) AS customer_name, -- cleaner to have one name column for the report.
		EXTRACT(YEAR FROM AGE('2014-02-09'::DATE, c.birthdate)) AS age -- using latest date from dataset as a historical snapshot rather than CURRENT_DATE for current data.
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
	LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
)
, customer_aggregations AS (
/* ----------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------- */
	SELECT 
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(order_date) AS last_order_date,
		EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan
	FROM base_query
	GROUP BY
		customer_key,
		customer_number,
		customer_name,
		age
)
/* ----------------------------------------------------------------------
3) Final Query: Combines all customer results into one output
---------------------------------------------------------------------- */
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,
	CASE
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_sales <= 5000 then 'Regular'
			WHEN lifespan < 12 THEN 'New'
			ELSE 'New'
		END AS customer_segment,
	last_order_date,
	EXTRACT(YEAR FROM AGE('2014-02-09'::DATE, last_order_date)) * 12 + EXTRACT(MONTH FROM AGE('2014-02-09'::DATE, last_order_date)) AS recency,
	lifespan,
	total_orders,
	total_sales,
	-- Compute average order value (AVO)
	CASE
		WHEN total_orders = 0 THEN 0 -- Catches any orders of $0
		ELSE total_sales / total_orders
	END AS avg_order_value,
	-- Computer average montly spend
	CASE
		WHEN lifespan = 0 THEN ROUND(total_sales, 2) -- if customer has less than 1 month history, then their average is equal to total_orders of that single month.
		ELSE ROUND(total_sales / lifespan, 2)
	END AS avg_monthly_spend,
	total_products,
	total_quantity	
FROM customer_aggregations
;
