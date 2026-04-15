/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products generate the highest revenue?
-- >> Simple ranking style
SELECT
	f.product_key,
	p.product_name,
	SUM(f.sales)
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY
	f.product_key,
	p.product_name
ORDER BY SUM(f.sales) DESC
LIMIT 5;
-- >> More complex but flexibly ranking style using a window function
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;
-- >> Window Function is good for a more complex report with multiple aggregate functions.
-- >> Simple 'LIMIT 5' is easier for a quick GROUP BY

-- What are the 5 worst-performing products in terms of sales?
SELECT
	f.product_key,
	p.product_name,
	SUM(f.sales)
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY
	f.product_key,
	p.product_name
ORDER BY SUM(f.sales) ASC
LIMIT 5;

-- Find the top 10 customers who have generated the highest revenue
SELECT *
FROM (
	SELECT
  	c.first_name,
  	c.last_name,
  	SUM(f.sales) as total_revenue,
  	ROW_NUMBER() OVER (ORDER BY SUM(f.sales) DESC) AS rank_customers
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
	GROUP BY c.first_name, c.last_name)
WHERE rank_customers <= 10;

-- Find the top 3 customers with the fewest orders placed
SELECT
	CONCAT(first_name, ' ', last_name) AS customer_name,
	total_orders,
	total_sales,
	product_name
FROM (
    SELECT
        c.first_name,
        c.last_name,
        COUNT(f.order_number) as total_orders,
        ROW_NUMBER() OVER (
            ORDER BY
                COUNT(f.order_number) ASC,
                SUM(f.sales) ASC,
				f.quantity ASC,
				MIN(f.order_date)
        ) AS rank_customers,
		SUM(f.sales) AS total_sales,
		p.product_name
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
	LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY c.first_name, c.last_name, f.quantity, p.product_name
) AS t
WHERE rank_customers <= 3;
