/*
-------------------------------------------------------------
Security DDL Script - Security Schema
-------------------------------------------------------------
Purpose:
- Creates SQL logins and database users
- Creates application roles (Client/Consultant/Manager/Executive)
- Creates row-level security views in security schema
- Grants access to views and schemas
-------------------------------------------------------------
*/

-- ====================================
-- Create logins
-- ====================================

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CLI-5001') 
    CREATE LOGIN [CLI-5001] WITH PASSWORD = 'Client@123';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CLI-5002') 
    CREATE LOGIN [CLI-5002] WITH PASSWORD = 'Client@456';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CON-1008') 
    CREATE LOGIN [CON-1008] WITH PASSWORD = 'Consultant@101';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CON-1009') 
    CREATE LOGIN [CON-1009] WITH PASSWORD = 'Consultant@456';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CON-1003') 
    CREATE LOGIN [CON-1003] WITH PASSWORD = 'Manager@623';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CON-1013') 
    CREATE LOGIN [CON-1013] WITH PASSWORD = 'Executive@276';
GO

USE [DataSecured];
GO

-- ====================================
-- Create users
-- ====================================

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CLI-5001') 
    CREATE USER [CLI-5001] FOR LOGIN [CLI-5001];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CLI-5002') 
    CREATE USER [CLI-5002] FOR LOGIN [CLI-5002];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CON-1008') 
    CREATE USER [CON-1008] FOR LOGIN [CON-1008];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CON-1009') 
    CREATE USER [CON-1009] FOR LOGIN [CON-1009];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CON-1003') 
    CREATE USER [CON-1003] FOR LOGIN [CON-1003];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CON-1013') 
    CREATE USER [CON-1013] FOR LOGIN [CON-1013];

-- ====================================
-- Create roles
-- ====================================

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ClientsRole' AND type = 'R') 
    CREATE ROLE ClientsRole;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ConsultantsRole' AND type = 'R') 
    CREATE ROLE ConsultantsRole;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ManagersRole' AND type = 'R') 
    CREATE ROLE ManagersRole;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ExecutivesRole' AND type = 'R') 
    CREATE ROLE ExecutivesRole;

-- ====================================
-- Add users to roles
-- ====================================

IF IS_ROLEMEMBER('ClientsRole', 'CLI-5001') IS NULL OR IS_ROLEMEMBER('ClientsRole', 'CLI-5001') = 0 
    ALTER ROLE [ClientsRole] ADD MEMBER [CLI-5001];
IF IS_ROLEMEMBER('ClientsRole', 'CLI-5002') IS NULL OR IS_ROLEMEMBER('ClientsRole', 'CLI-5002') = 0 
    ALTER ROLE [ClientsRole] ADD MEMBER [CLI-5002];
IF IS_ROLEMEMBER('ConsultantsRole', 'CON-1008') IS NULL OR IS_ROLEMEMBER('ConsultantsRole', 'CON-1008') = 0 
    ALTER ROLE [ConsultantsRole] ADD MEMBER [CON-1008];
IF IS_ROLEMEMBER('ConsultantsRole', 'CON-1009') IS NULL OR IS_ROLEMEMBER('ConsultantsRole', 'CON-1009') = 0 
    ALTER ROLE [ConsultantsRole] ADD MEMBER [CON-1009];
IF IS_ROLEMEMBER('ManagersRole', 'CON-1003') IS NULL OR IS_ROLEMEMBER('ManagersRole', 'CON-1003') = 0 
    ALTER ROLE [ManagersRole] ADD MEMBER [CON-1003];
IF IS_ROLEMEMBER('ExecutivesRole', 'CON-1013') IS NULL OR IS_ROLEMEMBER('ExecutivesRole', 'CON-1013') = 0 
    ALTER ROLE [ExecutivesRole] ADD MEMBER [CON-1013];

GO

-- ====================================
-- Create security views
-- ====================================

IF OBJECT_ID('security.vw_client_portal', 'V') IS NOT NULL
    DROP VIEW security.vw_client_portal;
GO

CREATE VIEW security.vw_client_portal AS
SELECT 
    c.client_id,
    c.client_name,
    c.industry,
    c.tier,
    p.project_id,
    p.project_name,
    p.project_type,
    p.start_date,
    p.end_date,
    p.status,
    i.invoice_id,
    i.invoice_date,
    i.due_date,
    i.total_hours,
    i.total_amount,
    i.payment_status
FROM core.crm_clients c
LEFT JOIN core.crm_projects p ON c.client_id = p.client_id
LEFT JOIN core.crm_invoices i ON p.project_id = i.project_id
WHERE c.client_id = USER_NAME();
GO

IF OBJECT_ID('security.vw_consultant_dashboard', 'V') IS NOT NULL
    DROP VIEW security.vw_consultant_dashboard;
GO

CREATE VIEW security.vw_consultant_dashboard AS
SELECT 
    con.consultant_id,
    con.first_name,
    con.last_name,
    con.job_title,
    con.security_clearance_level,
    con.office_location,
    pa.assignment_id,
    pa.project_id,
    p.project_name,
    p.client_id,
    c.client_name,
    pa.role_on_project,
    pa.allocation_percentage,
    pa.start_date,
    pa.end_date,
    t.timesheet_id,
    t.work_date,
    t.hours_worked,
    t.billable,
    t.activity_description
FROM core.hcm_consultants con
LEFT JOIN core.crm_project_assignments pa ON con.consultant_id = pa.consultant_id
LEFT JOIN core.crm_projects p ON pa.project_id = p.project_id
LEFT JOIN core.crm_clients c ON p.client_id = c.client_id
LEFT JOIN core.hcm_timesheets t ON con.consultant_id = t.consultant_id AND pa.project_id = t.project_id
WHERE con.consultant_id = USER_NAME();
GO

IF OBJECT_ID('security.vw_manager_dashboard', 'V') IS NOT NULL
    DROP VIEW security.vw_manager_dashboard;
GO

CREATE VIEW security.vw_manager_dashboard AS
SELECT 
    p.project_id,
    p.project_name,
    p.client_id,
    c.client_name,
    p.budget,
    p.status,
    pa.consultant_id,
    con.first_name + ' ' + con.last_name AS consultant_name,
    con.job_title,
    pa.role_on_project,
    pa.allocation_percentage,
    i.total_amount,
    i.payment_status
FROM core.crm_projects p
LEFT JOIN core.crm_clients c ON p.client_id = c.client_id
LEFT JOIN core.crm_project_assignments pa ON p.project_id = pa.project_id
LEFT JOIN core.hcm_consultants con ON pa.consultant_id = con.consultant_id
LEFT JOIN core.crm_invoices i ON p.project_id = i.project_id;
GO

IF OBJECT_ID('security.vw_executive_dashboard', 'V') IS NOT NULL
    DROP VIEW security.vw_executive_dashboard;
GO

CREATE VIEW security.vw_executive_dashboard AS
SELECT *
FROM analytics.dim_clients;
GO

-- ====================================
-- Grant Access
-- ====================================

GRANT SELECT ON security.vw_client_portal TO ClientsRole;
GRANT SELECT ON security.vw_consultant_dashboard TO ConsultantsRole;
GRANT SELECT ON security.vw_manager_dashboard TO ManagersRole;
GRANT SELECT ON SCHEMA::analytics TO ManagersRole;
GRANT SELECT ON SCHEMA::core TO ExecutivesRole;
GRANT SELECT ON SCHEMA::analytics TO ExecutivesRole;
GRANT SELECT ON SCHEMA::security TO ExecutivesRole;
GRANT SELECT ON core.crm_clients TO ClientsRole;
GRANT SELECT ON core.crm_projects TO ClientsRole;  
GRANT SELECT ON core.crm_invoices TO ClientsRole;
GRANT SELECT ON core.hcm_consultants TO ConsultantsRole;
GRANT SELECT ON core.crm_project_assignments TO ConsultantsRole;
GRANT SELECT ON core.hcm_timesheets TO ConsultantsRole;
GRANT SELECT ON SCHEMA::core TO ManagersRole;
GO
