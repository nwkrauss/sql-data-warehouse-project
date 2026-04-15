/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month
SELECT
	DATE_TRUNC('month', order_date)::DATE AS order_date,
	SUM(sales) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date) 
ORDER BY DATE_TRUNC('month', order_date);
-- and the running total of sales over time 
SELECT
	order_date::DATE,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY DATE_TRUNC('year', order_date) ORDER BY order_date) AS running_total_sales, -- partitioned by year so running total resets each year
	ROUND(AVG(avg_monthly_price) OVER (ORDER BY order_date)::NUMERIC, 2) AS moving_avg_price
FROM
	(
	SELECT
		DATE_TRUNC('month', order_date) AS order_date,
		SUM(sales) AS total_sales,
		AVG(price) AS avg_monthly_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATE_TRUNC('month', order_date)
	) t;
