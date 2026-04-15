/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: EXTRACT(), DATE_TRUNC(), TO_CHAR()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Analyze sales performance over time
-- >> with EXTRACT()
SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date);
-- >> with DATE_TRUNC()
SELECT
	DATE_TRUNC('month', order_date)::DATE AS order_date,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date)::DATE
ORDER BY DATE_TRUNC('month', order_date)::DATE;
-- >> with TO_CHAR()
SELECT
    TO_CHAR(order_date, 'yyyy-MM') AS order_date,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY TO_CHAR(order_date, 'yyyy-MM')
ORDER BY TO_CHAR(order_date, 'yyyy-MM');
