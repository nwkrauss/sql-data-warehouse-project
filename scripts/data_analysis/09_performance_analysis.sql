/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
	SELECT
		EXTRACT(YEAR FROM f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
	GROUP BY EXTRACT(YEAR FROM f.order_date), p.product_name
	)
SELECT
	order_year,
	product_name,
	current_sales,
	ROUND(AVG(current_sales) OVER (PARTITION BY product_name), 0) AS avg_yearly_sales,
	ROUND(current_sales - AVG(current_sales) OVER (PARTITION BY product_name), 0) AS diff_avg,
	CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		ELSE 'Avg'
		END AS yearly_performance,
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
	CASE
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No Change'
		END AS diff_py
FROM yearly_product_sales
ORDER BY product_name, order_year
;

-- Month Over Month analysis:
WITH montly_product_sales AS (
	SELECT
		EXTRACT(MONTH FROM f.order_date) AS order_month,
		p.product_name,
		SUM(f.sales) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
	GROUP BY EXTRACT(MONTH FROM f.order_date), p.product_name
	)
SELECT
	order_month,
	product_name,
	current_sales,
	ROUND(AVG(current_sales) OVER (PARTITION BY product_name), 0) AS avg_monthly_sales,
	ROUND(current_sales - AVG(current_sales) OVER (PARTITION BY product_name), 0) AS diff_avg,
	CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		ELSE 'Avg'
		END AS monthly_performance,
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) AS pm_sales,
	CASE
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) < 0 THEN 'Decrease'
		ELSE 'No Change'
		END AS diff_pm
FROM montly_product_sales
ORDER BY product_name, order_month
;
