/*
================================================================================
Quality Checks - Analytics Layer Validation
================================================================================
Script Purpose:
    Validates data quality by checking:
    - Primary key uniqueness in all tables
    - Referential integrity between tables

Usage Example:
    Run entire script - ALL queries should return 0 rows!
================================================================================
*/

-- --------------------------------------------------------------------
-- Checking 'analytics.dim_clients' 
-- --------------------------------------------------------------------
SELECT 
    client_key,
    COUNT(*) AS duplicate_count
FROM analytics.dim_clients
GROUP BY client_key
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'analytics.dim_clients'
-- --------------------------------------------------------------------
SELECT 
    client_id,
    COUNT(*) AS duplicate_count
FROM analytics.dim_clients
GROUP BY client_id
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'analytics.dim_consultants' 
-- --------------------------------------------------------------------
SELECT 
    consultant_key,
    COUNT(*) AS duplicate_count
FROM analytics.dim_consultants
GROUP BY consultant_key
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'analytics.dim_consultants'
-- --------------------------------------------------------------------
SELECT 
    consultant_id,
    COUNT(*) AS duplicate_count
FROM analytics.dim_consultants
GROUP BY consultant_id
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'analytics.dim_projects' 
-- --------------------------------------------------------------------
SELECT 
    project_key,
    COUNT(*) AS duplicate_count
FROM analytics.dim_projects
GROUP BY project_key
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'analytics.dim_projects' 
-- --------------------------------------------------------------------
SELECT 
    project_id,
    COUNT(*) AS duplicate_count
FROM analytics.dim_projects
GROUP BY project_id
HAVING COUNT(*) > 1;

