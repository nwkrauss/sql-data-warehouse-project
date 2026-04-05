# Data Warehouse and Analytics Project
Welcome to my **Data Warehouse and Analytics Project** repository! This project demonstrates a comprehensive data warehousing and analytics solution while highlighting industry best practices.

## Project Overview
The project involves:
1. **Data Architecture**: Designing a Modern Data Warehouse using Medallion Architecture (**Bronze**, **Silver**, and **Gold** layers).
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

I created this repository for my portfolio as a resource to showcase skills in:  
• SQL Development  
• Data Architecture  
• Data Engineering  
• ETL Pipeline Development  
• Data Modeling  
• Data Analytics  
  
### Step 1
#### I create these four folders in github:  
'datasets', 'docs', 'scripts', 'tests'  
-- each contains a 'placeholder' file to establish the folder.

### Step 2
#### I establish my database.  
-- I'm running PostGres with PgAdmin and start with this query:  
CREATE DATABASE DataWarehouse;  

-- Then I connect Query Tool to 'datawarehouse'.  
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
