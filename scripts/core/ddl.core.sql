/*
-------------------------------------------------------------
Create Core Tables - DDL Script
-------------------------------------------------------------
Purpose: 
Creates tables in the 'core' schema with proper data types.
Dropping existing tables if they already exist.
-------------------------------------------------------------
*/

-- CRM TABLES

IF OBJECT_ID('core.crm_clients', 'U') IS NOT NULL
    DROP TABLE core.crm_clients;
GO

CREATE TABLE core.crm_clients (
    client_id           VARCHAR(50),
    client_name         VARCHAR(200),
    industry            VARCHAR(50),
    country             VARCHAR(50),
    annual_revenue      INT,                  
    contract_value      DECIMAL(12,2),        
    tier                VARCHAR(50),
    onboarded_date      DATE
);
GO

IF OBJECT_ID('core.crm_projects', 'U') IS NOT NULL
    DROP TABLE core.crm_projects;
GO

CREATE TABLE core.crm_projects (
    project_id              VARCHAR(50),
    client_id               VARCHAR(50),
    project_name            VARCHAR(200),
    project_type            VARCHAR(50),
    start_date              DATE,
    end_date                DATE,                
    budget                  DECIMAL(12,2),       
    status                  VARCHAR(50),
    confidentiality_level   VARCHAR(100)
);
GO

IF OBJECT_ID('core.crm_project_assignments', 'U') IS NOT NULL
    DROP TABLE core.crm_project_assignments;
GO

CREATE TABLE core.crm_project_assignments (
    assignment_id           VARCHAR(50),
    project_id              VARCHAR(50),
    consultant_id           VARCHAR(50),
    role_on_project         VARCHAR(50),
    allocation_percentage   VARCHAR(10),         
    start_date              DATE,
    end_date                DATE                 
);
GO

IF OBJECT_ID('core.crm_invoices', 'U') IS NOT NULL
    DROP TABLE core.crm_invoices;
GO

CREATE TABLE core.crm_invoices (
    invoice_id      VARCHAR(50),
    client_id       VARCHAR(50),
    project_id      VARCHAR(50),
    invoice_date    DATE,
    due_date        DATE,                        
    total_hours     INT,                         
    total_amount    DECIMAL(12,2),               
    payment_status  VARCHAR(50),
    paid_date       DATE                        
);
GO

-- HCM TABLES

IF OBJECT_ID('core.hcm_consultants', 'U') IS NOT NULL
    DROP TABLE core.hcm_consultants;
GO

CREATE TABLE core.hcm_consultants (
    consultant_id               VARCHAR(50),
    first_name                  VARCHAR(100),
    last_name                   VARCHAR(100),
    email                       VARCHAR(200),    
    job_title                   VARCHAR(100),
    security_clearance_level    INT,         
    hire_date                   DATE,
    office_location             VARCHAR(50),
    billable_rate               DECIMAL(10,2)    
);
GO

IF OBJECT_ID('core.hcm_timesheets', 'U') IS NOT NULL
    DROP TABLE core.hcm_timesheets;
GO

CREATE TABLE core.hcm_timesheets (
    timesheet_id            VARCHAR(50),
    consultant_id           VARCHAR(50),
    project_id              VARCHAR(50),
    work_date               DATE,
    hours_worked            DECIMAL(4,2),        
    billable                VARCHAR(10),
    activity_description    VARCHAR(500),
    submitted_date          DATE
);
GO
