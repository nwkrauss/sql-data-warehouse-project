/*
=====================================================================================
DDL Script: Create Gold Views
=====================================================================================
Script Purpose:  
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer to 
    produce a clean, enriched, and business-ready dataset.

Usage:
    These views can be queried directly for analytics and reporting.
=====================================================================================
*/

-- =====================================================================================
-- Create Dimension: gold.dim_customers
-- =====================================================================================
CREATE OR REPLACE VIEW gold.dim_customers AS
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key, -- Surrogate Key
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		ci.cst_marital_status AS marital_status,
		CASE
			WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
			ELSE COALESCE(ca.gen, 'n/a')
		END AS gender,
		ca.bdate AS birthdate,
		la.cntry AS country,
		ci.cst_create_date AS create_date
	FROM silver.crm_cust_info ci
		LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
		LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;

-- =====================================================================================
-- Create Dimension: gold.dim_products
-- =====================================================================================
CREATE OR REPLACE VIEW gold.dim_products AS
	SELECT
		ROW_NUMBER() OVER (ORDER BY prd_start_dt, a.prd_id) AS product_key, -- Surrogate Key
		prd_id AS product_id,
		prd_key AS product_number,
		prd_nm AS product_name,
		prd_cost AS product_cost,
		CASE WHEN a.cat_id = b.id THEN a.cat_id
			ELSE a.cat_id
		END AS category_id,
		prd_line AS product_line,
		b.cat AS category,
		b.subcat AS subcategory,
		b.maintenance AS maintenance,
		prd_start_dt AS start_date
	FROM silver.crm_prd_info a
	LEFT JOIN silver.erp_px_cat_g1v2 b ON a.cat_id = b.id
	WHERE prd_end_dt IS NULL; -- Filtering out historical data
-- =====================================================================================
-- Create Fact Table: gold.fact_sales
-- =====================================================================================
CREATE OR REPLACE VIEW gold.fact_sales AS
	SELECT
		sd.sls_ord_num AS order_number,
		p.product_key,
		c.customer_key,
		sd.sls_order_dt AS order_date,
		sd.sls_ship_dt AS ship_date,
		sd.sls_due_dt AS due_date,
		sd.sls_price AS price,
		sd.sls_quantity AS quantity,
		sd.sls_sales AS sales
	FROM silver.crm_sales_details sd
	LEFT JOIN gold.dim_customers c ON sd.sls_cust_id = c.customer_id
	LEFT JOIN gold.dim_products p ON sd.sls_prd_key = p.product_number
	ORDER BY sls_order_dt;
