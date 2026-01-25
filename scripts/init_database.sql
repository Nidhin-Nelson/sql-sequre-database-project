/*
-------------------------------------------------------------
Create DataSecured Database 
-------------------------------------------------------------
Script Purpose:
    Creates the 'DataSecured' database
    Create schema for 'DataSecured'
    Create roles for 'DataSecured'

Architecture Overview:
    raw        - Source landing tables (ingested as is)
    core       - Cleaned and standardized enterprise data
    analytics  - BI ready fact and dimension models
    security   - Role and access control metadata

Role Overview:
    db_partner           
    db_manager           
    db_senior_consultant
    db_junior_consultant 
    db_finance           
    db_client_portal      

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

-- Create roles
CREATE ROLE db_partner;
CREATE ROLE db_manager;
CREATE ROLE db_senior_consultant;
CREATE ROLE db_junior_consultant;
CREATE ROLE db_finance;
CREATE ROLE db_client_portal;

GO

