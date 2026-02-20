/*
============================================================
Create Database and Schemas
============================================================
Script Purpose:  
    This script creates a new database named 'DataWarehouse'.
    Additionally, the script sets up three schemas within the database:
    'bronze', 'silver', and 'gold'.  

WARNING:
    Running this script will create a new database 'Datawarehouse'.
    If 'Datawarehouse' already exists, all data in the database
    might be permanently deleted. Proceed with caution and ensure
    you have proper backups before running this.
*/

-- Step 1
-- I'm running PostGres with PgAdmin. Start by creating a new database.
CREATE DATABASE DataWarehouse;

-- STEP 2
-- Now I can connect to 'datawarehouse' with the Query Tool.
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
