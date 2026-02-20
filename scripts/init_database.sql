-- I'm running PostGres with PgAdmin. 
-- Step 1:
CREATE DATABASE DataWarehouse;

-- Then I can connect to 'datawarehouse' with the Query Tool.
-- STEP 2:
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
