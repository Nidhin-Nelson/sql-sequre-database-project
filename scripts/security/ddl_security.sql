/*
-------------------------------------------------------------
Security Setup Script - Security Schema
-------------------------------------------------------------
Purpose:
- Creates SQL logins and database users
- Creates application roles (Client/Consultant/Manager/Executive)
- Creates row-level security views in [security] schema
- Grants access to views and schemas
-------------------------------------------------------------
*/

-- ====================================
-- Create logins
-- ====================================

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'C001') 
    CREATE LOGIN [C001] WITH PASSWORD = 'Client@123';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'C002') 
    CREATE LOGIN [C002] WITH PASSWORD = 'Client@456';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'EMP001') 
    CREATE LOGIN [EMP001] WITH PASSWORD = 'Consultant@101';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'EMP002') 
    CREATE LOGIN [EMP002] WITH PASSWORD = 'Consultant@456';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'MGR001') 
    CREATE LOGIN [MGR001] WITH PASSWORD = 'Manager@623';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'EXEC001') 
    CREATE LOGIN [EXEC001] WITH PASSWORD = 'Executive@276';
GO

USE [DataSecured];
GO

-- ====================================
-- Create users
-- ====================================

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'C001') 
    CREATE USER [C001] FOR LOGIN [C001];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'C002') 
    CREATE USER [C002] FOR LOGIN [C002];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'EMP001') 
    CREATE USER [EMP001] FOR LOGIN [EMP001];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'EMP002') 
    CREATE USER [EMP002] FOR LOGIN [EMP002];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'MGR001') 
    CREATE USER [MGR001] FOR LOGIN [MGR001];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'EXEC001') 
    CREATE USER [EXEC001] FOR LOGIN [EXEC001];

-- ====================================
-- Create roles
-- ====================================

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ClientRole' AND type = 'R') 
    CREATE ROLE [ClientRole];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ConsultantRole' AND type = 'R') 
    CREATE ROLE [ConsultantRole];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ManagerRole' AND type = 'R') 
    CREATE ROLE [ManagerRole];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ExecutiveRole' AND type = 'R') 
    CREATE ROLE [ExecutiveRole];

-- ====================================
-- Add users to roles
-- ====================================

IF IS_ROLEMEMBER('ClientRole', 'C001') = 0 ALTER ROLE [ClientRole] ADD MEMBER [C001];
IF IS_ROLEMEMBER('ClientRole', 'C002') = 0 ALTER ROLE [ClientRole] ADD MEMBER [C002];
IF IS_ROLEMEMBER('ConsultantRole', 'EMP001') = 0 ALTER ROLE [ConsultantRole] ADD MEMBER [EMP001];
IF IS_ROLEMEMBER('ConsultantRole', 'EMP002') = 0 ALTER ROLE [ConsultantRole] ADD MEMBER [EMP002];
IF IS_ROLEMEMBER('ManagerRole', 'MGR001') = 0 ALTER ROLE [ManagerRole] ADD MEMBER [MGR001];
IF IS_ROLEMEMBER('ExecutiveRole', 'EXEC001') = 0 ALTER ROLE [ExecutiveRole] ADD MEMBER [EXEC001];

GO

PRINT '=========================================================';
PRINT 'CREATING SECURITY VIEWS';
PRINT '=========================================================';

-- ====================================
-- Client View
-- ====================================

IF OBJECT_ID('security.vw_client_portal', 'V') IS NOT NULL
    DROP VIEW security.vw_client_portal;
GO

CREATE VIEW security.vw_client_portal AS
SELECT 
    -- Client info
    c.client_id,
    c.client_name,
    c.industry,
    c.tier,
    
    -- Project info
    p.project_id,
    p.project_name,
    p.project_type,
    p.start_date,
    p.end_date,
    p.status,

    -- Invoice info
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

-- ====================================
-- Consultant View
-- ====================================

IF OBJECT_ID('security.vw_consultant_dashboard', 'V') IS NOT NULL
    DROP VIEW security.vw_consultant_dashboard;
GO

CREATE VIEW security.vw_consultant_dashboard AS
SELECT 
    -- Consultant info 
    con.consultant_id,
    con.first_name,
    con.last_name,
    con.job_title,
    con.security_clearance_level,
    con.office_location,
    
    -- Assignment info
    pa.assignment_id,
    pa.project_id,
    p.project_name,
    p.client_id,
    c.client_name,
    pa.role_on_project,
    pa.allocation_percentage,
    pa.start_date,
    pa.end_date,
    
    -- Timesheet info
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

-- ====================================
-- Manage views
-- ====================================

IF OBJECT_ID('security.vw_manager_dashboard', 'V') IS NOT NULL
    DROP VIEW security.vw_manager_dashboard;
GO

CREATE VIEW security.vw_manager_dashboard AS
SELECT 
    -- Project summary
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

-- ====================================
-- Executive view
-- ====================================

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

GRANT SELECT ON security.vw_client_portal TO ClientRole;

GRANT SELECT ON security.vw_consultant_dashboard TO ConsultantRole;

GRANT SELECT ON security.vw_manager_dashboard TO ManagerRole;
GRANT SELECT ON SCHEMA::analytics TO ManagerRole;

GRANT SELECT ON SCHEMA::core TO ExecutiveRole;
GRANT SELECT ON SCHEMA::analytics TO ExecutiveRole;
GRANT SELECT ON SCHEMA::security TO ExecutiveRole;



