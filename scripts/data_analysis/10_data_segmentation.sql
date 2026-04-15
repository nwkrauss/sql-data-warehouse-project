/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/* Segment products into cost ranges and
count how many products fall into each segment */
WITH product_segments AS (
	SELECT
		product_key,
		product_name,
		product_cost,
		CASE
			WHEN product_cost < 100 THEN 'Below 100'
			WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END cost_range
	FROM gold.dim_products)
SELECT
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY
	CASE cost_range
		WHEN 'Below 100' THEN 1
        WHEN '100-500' THEN 2
        WHEN '500-1000' THEN 3
        WHEN 'Above 1000' THEN 4
	END
;

/* Group customers into three segments based on their spending behavior:
    - VIP: Customers with at least 12 months of history and spending more than $5000
	- Regular: Customers with at least 12 months of history but spending $5000 or less
	- New: Customers with a lifespan less than 12 months
And find the total number of customers by each group. */
WITH customer_spending AS (
	SELECT
		c.first_name,
		c.last_name,
		f.customer_key,
		SUM(f.sales) AS total_sales,
		MIN(f.order_date) AS first_order,
		MAX(f.order_date) AS last_order,
		(EXTRACT(YEAR FROM AGE(MAX(f.order_date), MIN(f.order_date))) * 12) + EXTRACT(MONTH FROM AGE(MAX(f.order_date), MIN(f.order_date))) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
	GROUP BY c.first_name, c.last_name, f.customer_key
	)
SELECT
	segment,
	COUNT(customer_key) AS total_customers,
	TO_CHAR(SUM(total_sales), '$999,999,999') AS total_sales
FROM (
	SELECT
		first_name,
		last_name,
		customer_key,
		total_sales,
		first_order,
		last_order,
		lifespan,
		CASE
			WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_sales <= 5000 then 'Regular'
			ELSE 'New'
		END AS segment
	FROM customer_spending) t
GROUP BY segment
ORDER BY total_sales DESC;
