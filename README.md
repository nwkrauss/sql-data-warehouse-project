# SQL Data Warehouse Project
Building a modern data warehouse with SQL Server, including ETL process, data modeling, and analytics.  
  
### Step 1
#### I create these four folders in github:  
'datasets', 'docs', 'scripts', 'tests'  
-- each contains a 'placeholder' file to establish the folder.

### Step 2
#### I need to establish my database.  
-- I'm running PostGres with PgAdmin and start with this query:  
CREATE DATABASE DataWarehouse;  

-- Then connect Query Tool to 'datawarehouse'  
-- In the new Query Tool that is connected to 'datawarehouse':  
CREATE SCHEMA bronze;  
CREATE SCHEMA silver;  
CREATE SCHEMA gold;  

-- In github, I go into the 'scripts' folder and create a new file 'init_database.sql'  
-- In this file, I include the code used in this step.  
-- I also include, at the top, a "sticky note" that explains what the file is.  This is the note:  
  
'Create Database and Schemas
Script Purpose:  
This script creates a new database named 'DataWarehouse'.
Additionally, the script sets up three schemas within the database:
'bronze', 'silver', and 'gold'.  
  
WARNING:
Running this script will create a new database 'Datawarehouse'.
If 'Datawarehouse' already exists, all data in the database
might be permanently deleted. Proceed with caution and ensure
you have proper backups before running this.'

### Step 3  
