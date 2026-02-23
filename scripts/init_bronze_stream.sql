/*
=================================================================
Stream Data from Source Files Into Tables in the Bronze Layer
=================================================================
Script Purpose:  
    This script executes a TRUNCATE and then batch load for each
	table in the bronze layer. It serves as a 'refresh' for data
	from the source files.
*/

TRUNCATE TABLE bronze.crm_cust_info;
COPY bronze.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	)
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');

TRUNCATE TABLE bronze.crm_prd_info;
COPY bronze.crm_prd_info(
	prd_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');

TRUNCATE TABLE bronze.crm_sales_details;
COPY bronze.crm_sales_details(
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
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');

TRUNCATE TABLE bronze.erp_cust_az12;
COPY bronze.erp_cust_az12 (cid, bdate, gen)
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');

TRUNCATE TABLE bronze.erp_loc_a101;
COPY bronze.erp_loc_a101 (cid, cntry)
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');

TRUNCATE TABLE bronze.erp_px_cat_g1v2;
COPY bronze.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');
