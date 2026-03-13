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
-- >> Expectation: Only pre-defined values present ('Male', 'Female', 'n/a')
SELECT DISTINCT(cst_marital_status)
FROM silver.crm_cust_info;
SELECT DISTINCT(cst_gndr)
FROM silver.crm_cust_info;

-- Verify cst_create_date column contains real dates and is correct DATE type.
-- >> Expectation: No result.
SELECT *
FROM silver.crm_cust_info
WHERE LENGTH(cst_create_date::TEXT) != 10;
