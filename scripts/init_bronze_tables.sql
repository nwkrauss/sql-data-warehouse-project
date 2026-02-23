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
/* The code stored in this comment is what I actually used within PostgreSQL.

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

-- I include this step to verify the row count in the table matches the source file.
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

-- This COPY didn't work because 'sls_order_dt' contains some rows
-- with '0' instead of proper DATE format. I will go through and ALTER
-- the data type of the column to be able to ingest, then change '0' to 
-- NULL, and then ALTER again back to the DATE type.

ALTER TABLE bronze.crm_sales_details 
ALTER COLUMN sls_order_dt TYPE VARCHAR(50);

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt = '0';

UPDATE bronze.crm_sales_details
SET sls_order_dt = NULL
WHERE sls_order_dt = '0';

-- This query looks for records in the column that are not 8 characters long.
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt !~'^\d{8}$';
-- I found two entries still throwing me off: "32154" and "5489"

UPDATE bronze.crm_sales_details
SET sls_order_dt = NULL
WHERE sls_order_dt = '32154';

UPDATE bronze.crm_sales_details
SET sls_order_dt = NULL
WHERE sls_order_dt = '5489';

-- Now I can convert to DATE.
ALTER TABLE bronze.crm_sales_details 
ALTER COLUMN sls_order_dt TYPE DATE 
USING to_date(sls_order_dt, 'YYYYMMDD');

-- Moving onto the ERP tables.
COPY bronze.erp_cust_az12 (cid, bdate, gen)
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');

-- I hit an issue on the COPY due to unexpected formatting in 'bdate'.
ALTER TABLE bronze.erp_cust_az12
ALTER COLUMN bdate TYPE VARCHAR(50);

ALTER TABLE bronze.erp_cust_az12
ALTER COLUMN bdate TYPE DATE 
USING to_date(bdate, 'YYYY-MM-DD')

-- All good there, now moving on to the next tables.
COPY bronze.erp_loc_a101 (cid, cntry)
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');

COPY bronze.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
FROM '/Users/saxifrage/Desktop/Business/Data Analytics/Udemy Data Warehouse/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
WITH (FORMAT CSV, HEADER true, DELIMITER ',');
*/


