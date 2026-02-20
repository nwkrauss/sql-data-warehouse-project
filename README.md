# SQL Data Warehouse Project
Building a modern data warehouse with SQL Server, including ETL process, data modeling, and analytics.  
  
### Step 1
#### create folders
datasets, docs, scripts, tests  
*each containing 'placeholder'*

### Step 2
I'm running PostGres with PgAdmin. I start with this  
CREATE DATABASE DataWarehouse;  

Then connect Query Tool to 'datawarehouse':  
CREATE SCHEMA bronze;  
CREATE SCHEMA silver;  
CREATE SCHEMA gold;  

In github, I go into the 'scripts' folder and create a new file 'init_database.'
