/*
================================================================================
Quality Checks - Core Layer Validation
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
-- Checking 'core.crm_clients'
-- --------------------------------------------------------------------
SELECT 
    client_id,
    COUNT(*) AS duplicate_count
FROM core.crm_clients
GROUP BY client_id
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'core.crm_projects'
-- --------------------------------------------------------------------
SELECT 
    project_id,
    COUNT(*) AS duplicate_count
FROM core.crm_projects
GROUP BY project_id
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'core.crm_invoices'
-- --------------------------------------------------------------------
SELECT 
    invoice_id,
    COUNT(*) AS duplicate_count
FROM core.crm_invoices
GROUP BY invoice_id
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'core.hcm_consultants'
-- --------------------------------------------------------------------
SELECT 
    consultant_id,
    COUNT(*) AS duplicate_count
FROM core.hcm_consultants
GROUP BY consultant_id
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'core.hcm_timesheets'
-- --------------------------------------------------------------------
SELECT 
    timesheet_id,
    COUNT(*) AS duplicate_count
FROM core.hcm_timesheets
GROUP BY timesheet_id
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- Checking 'core.crm_project_assignments'
-- --------------------------------------------------------------------
SELECT 
    assignment_id,
    COUNT(*) AS duplicate_count
FROM core.crm_project_assignments
GROUP BY assignment_id
HAVING COUNT(*) > 1;
