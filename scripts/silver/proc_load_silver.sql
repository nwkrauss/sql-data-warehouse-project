/*
=====================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=====================================================================================
Script Purpose:  
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema. 
Actions Performed:
    - Truncates 'silver' tables.
    - Inserts transformed and cleaned data from 'bronze' into 'silver' tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL silver.load_silver();
=====================================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
	v_start_time TIMESTAMP;
	v_end_time TIMESTAMP;
	v_duration INTERVAL;
	v_table_start TIMESTAMP;
BEGIN
	v_start_time := clock_timestamp();
	BEGIN
		RAISE NOTICE '==================================================';
		RAISE NOTICE 'Loading Silver Layer';
		RAISE NOTICE '==================================================';
	
		RAISE NOTICE '--------------------------------------------------';
		RAISE NOTICE 'Loading CRM Tables';
		RAISE NOTICE '--------------------------------------------------';
	
		RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
			)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE
				WHEN cst_marital_status = 'M' THEN 'Married'
				WHEN cst_marital_status = 'S' THEN 'Single'
				ELSE 'n/a'
			END cst_marital_status,
			CASE
				WHEN cst_gndr = 'F' THEN 'Female'
				WHEN cst_gndr = 'M' THEN 'Male'
				ELSE 'n/a'
			END cst_gndr,
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			ORDER BY flag_last DESC
			) AS subquery
		WHERE flag_last = 1
			AND cst_id IS NOT NULL;
		RAISE NOTICE '>> Table silver.crm_cust_info >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';

		RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;

		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: silver.prd_cust_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
			)
		SELECT
			prd_id,
			REPLACE (SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
			prd_nm,
			COALESCE(prd_cost, 0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
				END AS prd_line,
			prd_start_dt,
			LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt
		FROM bronze.crm_prd_info;
		RAISE NOTICE '>> Table silver.crm_cust_info >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';

		RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
		
		RAISE NOTICE '>> Table silver.crm_sales_details >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
			)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN LENGTH(sls_order_dt) != 8 THEN NULL
				ELSE CAST(sls_order_dt AS DATE)
			END AS sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			CASE
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
				END AS sls_sales,
			sls_quantity,
			CASE
				WHEN sls_price IS NULL OR sls_price <= 0
				THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price
				END AS sls_price
		FROM bronze.crm_sales_details;
		
		RAISE NOTICE '--------------------------------------------------';
		RAISE NOTICE 'Loading ERP Tables';
		RAISE NOTICE '--------------------------------------------------';

		RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
	
		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
			)
		SELECT
			CASE 
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
				ELSE cid
				END AS cid,
			CASE
				WHEN EXTRACT(YEAR FROM bdate::DATE) > EXTRACT(YEAR FROM CURRENT_DATE)
				THEN NULL
				ELSE bdate::DATE
				END AS bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
				END AS gen
		FROM
			bronze.erp_cust_az12;
		RAISE NOTICE '>> Table silver.erp_cust_az12 >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
	
		RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
	
		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (cid, cntry)
		SELECT
			REPLACE(cid, '-', '') AS cid,
			CASE
				WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States of America'
				WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
				END as cntry
		FROM bronze.erp_loc_a101;
		RAISE NOTICE '>> Table silver.erp_loc_a101 >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
	
		RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
	
		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
			)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		RAISE NOTICE '>> Table silver.erp_px_cat_g1v2 >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
	
		EXCEPTION
			WHEN OTHERS THEN
				RAISE EXCEPTION '==================================================
	ERROR OCCURED DURING LOADING SILVER LAYER
	Error Message: %
	Error Code: %
	Load Failed After % Seconds
	==================================================',
		SQLERRM,
		SQLSTATE,
		EXTRACT(EPOCH FROM (clock_timestamp() - v_start_time));
	END;
	v_end_time := clock_timestamp();
	v_duration := v_end_time - v_start_time;
	RAISE NOTICE '==================================================';
	RAISE NOTICE 'Loading Silver Layer is Completed';
	RAISE NOTICE '>> Full Load Duration: % Seconds', EXTRACT(EPOCH FROM v_duration);
	RAISE NOTICE '==================================================';
END;
$$;
