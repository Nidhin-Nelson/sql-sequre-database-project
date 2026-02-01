/*
--------------------------------------------------------------------------------
DDL Script: Create Analytics Layer Views
--------------------------------------------------------------------------------
Purpose:
    This script creates views for the Analytics layer in the data warehouse. 
    The Analytics layer represents the final dimension and fact tables (Star Schema)
    Each view performs transformations and combines data from the Core layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics, reporting, and dashboards.
--------------------------------------------------------------------------------
*/


-- -----------------------------------------------------------------------------
-- Create Dimension: analytics.dim_clients
-- -----------------------------------------------------------------------------
IF OBJECT_ID('analytics.dim_clients', 'V') IS NOT NULL
    DROP VIEW analytics.dim_clients;
GO

CREATE VIEW analytics.dim_clients AS
SELECT
    ROW_NUMBER() OVER (ORDER BY c.client_id) AS client_key, -- Surrogate key
    c.client_id,
    c.client_name,
    c.industry,
    c.country,
    c.annual_revenue,
    c.contract_value,
    c.tier,
    c.onboarded_date,

    DATEDIFF(MONTH, c.onboarded_date, GETDATE()) AS months_as_client,
    
    -- Contract value tier
    CASE 
        WHEN c.contract_value >= 1000000 THEN 'Enterprise'
        WHEN c.contract_value >= 500000 THEN 'Large'
        WHEN c.contract_value >= 100000 THEN 'Medium'
        WHEN c.contract_value >= 50000 THEN 'Small'
        ELSE 'Starter'
    END AS client_segment,
    
    -- Revenue tier
    CASE 
        WHEN c.annual_revenue >= 10000000 THEN 'High Revenue'
        WHEN c.annual_revenue >= 1000000 THEN 'Medium Revenue'
        ELSE 'Low Revenue'
    END AS revenue_tier,
    
    -- Business metrics
    COUNT(DISTINCT p.project_id) AS total_projects,
    COUNT(DISTINCT CASE WHEN p.status = 'ACTIVE' THEN p.project_id END) AS active_projects,
    COUNT(DISTINCT CASE WHEN p.status = 'COMPLETED' THEN p.project_id END) AS completed_projects,
    SUM(CASE WHEN i.payment_status != 'PAID' THEN i.total_amount ELSE 0 END) AS outstanding_amount

FROM core.crm_clients c
LEFT JOIN core.crm_projects p ON c.client_id = p.client_id
LEFT JOIN core.crm_invoices i ON c.client_id = i.client_id
GROUP BY 
    c.client_id, c.client_name, c.industry, c.country, 
    c.annual_revenue, c.contract_value, c.tier, c.onboarded_date;
GO

-- -----------------------------------------------------------------------------
-- Create Dimension: analytics.dim_consultants
-- -----------------------------------------------------------------------------
IF OBJECT_ID('analytics.dim_consultants', 'V') IS NOT NULL
    DROP VIEW analytics.dim_consultants;
GO

CREATE VIEW analytics.dim_consultants AS
SELECT
    ROW_NUMBER() OVER (ORDER BY con.consultant_id) AS consultant_key, -- Surrogate key
    con.consultant_id,
    con.first_name,
    con.last_name,
    con.first_name + ' ' + con.last_name AS full_name,
    con.email,
    con.job_title,
    con.security_clearance_level,
    con.hire_date,
    con.office_location,
    con.billable_rate,
    
    -- Employment metrics
    DATEDIFF(MONTH, con.hire_date, GETDATE()) AS months_employed,

    -- Seniority Tier
    CASE 
        WHEN DATEDIFF(YEAR, con.hire_date, GETDATE()) >= 10 THEN 'Senior '
        WHEN DATEDIFF(YEAR, con.hire_date, GETDATE()) >= 5 THEN 'Mid-Level'
        WHEN DATEDIFF(YEAR, con.hire_date, GETDATE()) >= 2 THEN 'Junior'
        ELSE 'Entry Level'
    END AS seniority_level,
    
    -- Rate Tier
    CASE 
        WHEN con.billable_rate >= 300 THEN 'Premium '
        WHEN con.billable_rate >= 200 THEN 'High '
        WHEN con.billable_rate >= 100 THEN 'Standard '
        ELSE 'Entry '
    END AS rate_category,
    
    -- Project assignments
    COUNT(DISTINCT pa.project_id) AS total_projects_assigned,
    COUNT(DISTINCT CASE WHEN pa.role_on_project = 'Lead' THEN pa.project_id END) AS projects_as_lead

FROM core.hcm_consultants con
LEFT JOIN core.crm_project_assignments pa ON con.consultant_id = pa.consultant_id
GROUP BY 
    con.consultant_id, con.first_name, con.last_name, con.email, 
    con.job_title, con.security_clearance_level, con.hire_date, 
    con.office_location, con.billable_rate;
GO

-- -----------------------------------------------------------------------------
-- Create Dimension: analytics.dim_projects
-- -----------------------------------------------------------------------------
IF OBJECT_ID('analytics.dim_projects', 'V') IS NOT NULL
    DROP VIEW analytics.dim_projects;
GO

CREATE VIEW analytics.dim_projects AS
SELECT
    ROW_NUMBER() OVER (ORDER BY p.project_id) AS project_key, -- Surrogate key
    p.project_id,
    p.client_id,
    c.client_name,
    p.project_name,
    p.project_type,
    p.start_date,
    p.end_date,
    p.budget,
    p.status,
    p.confidentiality_level,
    
    -- Project duration
    DATEDIFF(MONTH, p.start_date, COALESCE(p.end_date, GETDATE())) AS project_duration_months,
    
    -- Project age
    DATEDIFF(DAY, p.start_date, GETDATE()) AS days_since_start,
    
    -- Duration category
    CASE 
        WHEN DATEDIFF(MONTH, p.start_date, COALESCE(p.end_date, GETDATE())) >= 12 THEN 'Long-term '
        WHEN DATEDIFF(MONTH, p.start_date, COALESCE(p.end_date, GETDATE())) >= 6 THEN 'Medium-term '
        ELSE 'Short-term '
    END AS duration_category,
    
    -- Budget category
    CASE 
        WHEN p.budget >= 1000000 THEN 'Large '
        WHEN p.budget >= 500000 THEN 'Medium '
        WHEN p.budget >= 100000 THEN 'Small '
        ELSE 'Micro '
    END AS budget_category,
    
    -- Team size
    COUNT(DISTINCT pa.consultant_id) AS team_size

FROM core.crm_projects p
LEFT JOIN core.crm_clients c ON p.client_id = c.client_id
LEFT JOIN core.crm_project_assignments pa ON p.project_id = pa.project_id
GROUP BY 
    p.project_id, p.client_id, c.client_name, p.project_name, 
    p.project_type, p.start_date, p.end_date, p.budget, 
    p.status, p.confidentiality_level;
GO

-- -----------------------------------------------------------------------------
-- Create Fact Table: analytics.fact_invoices
-- -----------------------------------------------------------------------------
IF OBJECT_ID('analytics.fact_invoices', 'V') IS NOT NULL
    DROP VIEW analytics.fact_invoices;
GO

CREATE VIEW analytics.fact_invoices AS
SELECT
    i.invoice_id,
    dc.client_key,
    
    -- Original attributes
    i.invoice_date,
    i.due_date,
    i.paid_date,
    i.total_hours,
    i.total_amount,
    i.payment_status
    

FROM core.crm_invoices i
LEFT JOIN analytics.dim_clients dc ON i.client_id = dc.client_id
LEFT JOIN analytics.dim_projects dp ON i.project_id = dp.project_id;
GO

-- -----------------------------------------------------------------------------
-- Create Fact Table: analytics.fact_project_assignments
-- -----------------------------------------------------------------------------
IF OBJECT_ID('analytics.fact_project_assignments', 'V') IS NOT NULL
    DROP VIEW analytics.fact_project_assignments;
GO

CREATE VIEW analytics.fact_project_assignments AS
SELECT
    pa.assignment_id,
    dcon.consultant_key,
    dp.project_key,
    
    -- Original attributes
    pa.role_on_project,
    pa.allocation_percentage,
    pa.start_date,
    pa.end_date,
    
    -- Calculated metrics
    DATEDIFF(MONTH, pa.start_date, COALESCE(pa.end_date, GETDATE())) AS assignment_duration_months,
    
    -- Is assignment active
    CASE 
        WHEN pa.end_date IS NULL OR pa.end_date >= GETDATE() THEN 'Active'
        ELSE 'Completed' 
    END AS is_active_assignment

FROM core.crm_project_assignments pa
LEFT JOIN analytics.dim_consultants dcon ON pa.consultant_id = dcon.consultant_id
LEFT JOIN analytics.dim_projects dp ON pa.project_id = dp.project_id;
GO

PRINT '============================================================';
PRINT 'Analytics Layer Views Created Successfully';
PRINT '============================================================';


