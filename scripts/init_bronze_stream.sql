/*
=================================================================
Stream Data from Source Files into Tables in the Bronze Layer
=================================================================
Script Purpose:  
    This script executes a TRUNCATE and then BATCH LOAD for all
	tables in the Bronze Layer. It serves as a 'refresh' for data
	from the source files.
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
		RAISE NOTICE 'Loading Bronze Layer';
		RAISE NOTICE '==================================================';
	
		RAISE NOTICE '--------------------------------------------------';
		RAISE NOTICE 'Loading CRM Tables';
		RAISE NOTICE '--------------------------------------------------';
	
		RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
		COPY bronze.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
		FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
		WITH (FORMAT CSV, HEADER true, DELIMITER ',');
		RAISE NOTICE '>> Table bronze.crm_cust_info >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
	
		RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
		COPY bronze.crm_prd_info(prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
		FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
		WITH (FORMAT CSV, HEADER true, DELIMITER ',');
		RAISE NOTICE '>> Table bronze.crm_prd_info >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
	
		RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
		COPY bronze.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
		FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
		WITH (FORMAT CSV, HEADER true, DELIMITER ',');
		RAISE NOTICE '>> Table bronze.crm_sales_details >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
	
		RAISE NOTICE '--------------------------------------------------';
		RAISE NOTICE 'Loading ERP Tables';
		RAISE NOTICE '--------------------------------------------------';
	
		RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
	
		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
		COPY bronze.erp_cust_az12 (cid, bdate, gen)
		FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
		WITH (FORMAT CSV, HEADER true, DELIMITER ',');
		RAISE NOTICE '>> Table bronze.erp_cust_az12 >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
	
		RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
	
		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
		COPY bronze.erp_loc_a101 (cid, cntry)
		FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
		WITH (FORMAT CSV, HEADER true, DELIMITER ',');
		RAISE NOTICE '>> Table bronze.erp_loc_a101 >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
	
		RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	
		v_table_start := clock_timestamp();
		RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		COPY bronze.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
		FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
		WITH (FORMAT CSV, HEADER true, DELIMITER ',');
		RAISE NOTICE '>> Table bronze.erp_px_cat_g1v2 >> Load Duration: % Seconds', EXTRACT (EPOCH FROM (clock_timestamp() - v_table_start));
		RAISE NOTICE '>> -------------------------';
	
		EXCEPTION
			WHEN OTHERS THEN
			RAISE NOTICE '==================================================';
			RAISE NOTICE 'ERROR OCCURED DURING LOADING BRONZE LAYER';
			RAISE NOTICE 'Error Message: %', SQLERRM;
			RAISE NOTICE 'Error Code: %', SQLSTATE;
			RAISE NOTICE '==================================================';
	END;
	v_end_time := clock_timestamp();
	v_duration := v_end_time - v_start_time;
	RAISE NOTICE '==================================================';
	RAISE NOTICE 'Loading Bronze Layer is Completed';
	RAISE NOTICE '>> Full Load Duration: % Seconds', EXTRACT(EPOCH FROM v_duration);
	RAISE NOTICE '==================================================';
END;
$$;
