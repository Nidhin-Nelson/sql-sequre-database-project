/*
-------------------------------------------------------------
Create DataSecured Database 
-------------------------------------------------------------
Script Purpose:
    Creates the 'DataSecured' database

Architecture Overview:
    raw        - Source landing tables (ingested as is)
    core       - Cleaned and standardized enterprise data
    analytics  - BI ready fact and dimension models
    semantic   - Business friendly consumption views
    security   - Role and access control metadata
    audit      - Load tracking and governance logs

WARNING:

    DROPS existing 'DataSecured' database and ALL data.
    Ensure backups exist before running this script.
*/

USE master;
GO

-- Drop and recreate the DataSecured database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataSecured')
BEGIN
    DROP DATABASE DataSecured;
END;
GO

-- Create the DataSecured database
CREATE DATABASE DataSecured;
GO

USE DataSecured;
GO

-- Create schemas
CREATE SCHEMA raw;
GO

CREATE SCHEMA core;
GO

CREATE SCHEMA analytics;
GO

CREATE SCHEMA security;
GO

