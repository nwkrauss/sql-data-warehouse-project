/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Retrieve a list of all tables in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema != 'pg_catalog' AND table_schema != 'information_schema'
ORDER BY table_schema;

-- Retrieve all columns for a specific table (dim_customers)
SELECT
    column_name, 
    data_type, 
    is_nullable, 
    character_maximum_length
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'dim_customers'
ORDER BY ordinal_position;
