/*
============================================================
Create Database and Schemas
============================================================
Script Purpose:
Warning:
  */

-- Step 1
-- I'm running PostGres with PgAdmin. Start by creating a new database.
CREATE DATABASE DataWarehouse;

-- STEP 2
-- Now I can connect to 'datawarehouse' with the Query Tool.
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
