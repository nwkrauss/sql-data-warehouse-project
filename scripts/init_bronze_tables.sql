/*
============================================================
Create Tables in the Bronze Layer
============================================================
Script Purpose:  
    The first part of this script creates six empty tables
	within the bronze layer. The tables are 1 to 1 equivalents
	of the source files.

	The second part of this script uses COPY to batch import the data
	from .csv files into the tables.
*/

-- Step 1
CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date DATE
);

CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key VARCHAR(50),
	prd_nm VARCHAR(50),
	prd_cost INT,
	prd_line VARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
);

CREATE TABLE bronze.crm_sales_details (
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

CREATE TABLE bronze.erp_cust_az12 (
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50)
);

CREATE TABLE bronze.erp_loc_a101 (
	cid VARCHAR(50),
	cntry VARCHAR(50)
);

CREATE TABLE bronze.erp_px_cat_g1v2 (
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)
);

-- Step 2
/* The code stored in this comment is for use within PostgreSQL.
The code that follows *after* the comment show the same functions
for use in standard ANSI SQL syntax.

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
DELIMITER ','
CSV HEADER;

/* I include this step to verify the row count in the table
matches the source file. */
SELECT COUNT(*) FROM bronze.crm_cust_info;

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
DELIMITER ','
CSV HEADER;

SELECT COUNT(*) FROM bronze.crm_prd_info;

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
DELIMITER ','
CSV HEADER;

ERROR:  date/time field value out of range: "0"
HINT:  Perhaps you need a different "DateStyle" setting.
CONTEXT:  COPY crm_sales_details, line 35321, column sls_order_dt: "0"
*/
BULK INSERT bronze.crm_cust_info
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
WITH
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
;


