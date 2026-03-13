/*
=====================================================================================
Quality Checks
=====================================================================================
Script Purpose:  
    This script performs various quality checks for data consistency, accuracy, and 
    standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consitency.
    - Invaild date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading the 'silver' layer.
    - Investigate and resolve any discrepencies found during the checks.
=====================================================================================
*/

-- =====================================================================================
-- Checking silver.crm_cust_info
-- =====================================================================================
-- Check for Nulls and Duplicates in primary key.
-- >> Expectation: No Result
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces.
-- >> Expectation: No Result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check for data standardization and consistency.
-- >> Expectation: 'Male', 'Female', 'n/a'
SELECT DISTINCT(cst_marital_status)
FROM silver.crm_cust_info;
SELECT DISTINCT(cst_gndr)
FROM silver.crm_cust_info;

-- Verify cst_create_date column contains real dates and is correct DATE type.
-- >> Expectation: No result.
SELECT *
FROM silver.crm_cust_info
WHERE LENGTH(cst_create_date::TEXT) != 10;


-- =====================================================================================
-- Checking silver.crm_prd_info
-- =====================================================================================
-- Check for Nulls and Duplicates in primary key.
-- >> Expectation: No Result
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for spaces in prd_nm
-- >> Expectation: No Result
SELECT *
FROM silver.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm;

-- Check for incorrect values in prd_cost
-- >> Expectation: Return '0'
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 1 OR prd_cost IS NULL;

-- Check for distinct values in prd_line
-- >> Expectation: 'Other Sales', 'n/a', 'Road', 'Mountain', 'Touring'
SELECT DISTINCT(prd_line)
FROM silver.crm_prd_info;

-- Check for invalid date orders
-- >> Expectation: No Result
SELECT * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- =====================================================================================
-- Checking silver.crm_sales_details
-- =====================================================================================
-- Check for invalid order dates
-- >> Expectation: No Result
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt;

-- Check for invalid sales data
-- >> Expectation: No Result
SELECT * FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;


-- =====================================================================================
-- Checking silver.erp_cust_az12
-- =====================================================================================
-- Check for invalid birth dates
-- >> Expectation: No Result
SELECT * FROM silver.erp_cust_az12
WHERE EXTRACT(YEAR FROM bdate) > EXTRACT(YEAR FROM CURRENT_DATE);

-- Check for bad values in gen column
-- >> Expectation: 'Male', 'Female', 'n/a'
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


-- =====================================================================================
-- Checking silver.erp_loc_a101
-- =====================================================================================
-- -- Check for bad values in cntry
-- >> Expectation: 'France', 'United Kingdom', 'United States of America', 'n/a',
-- 'Australia', 'Germany', 'Canada'
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;


-- =====================================================================================
-- Checking silver.erp_px_cat_g1v2
-- =====================================================================================
-- Check for data standardization
-- >> Expectation: No Result
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2
WHERE cat != 'Bikes' AND cat != 'Accessories' AND cat != 'Clothing' AND cat != 'Components';
