/*
-------------------------------------------------------------
Row Level Security - Security Layer
-------------------------------------------------------------
- Creates 3 security predicates and policies for core tables
- Prevents users from accessing delicate data
-------------------------------------------------------------
*/

-- Drop existing policies if they exist
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'ClientDataSecurityPolicy')
    DROP SECURITY POLICY security.ClientDataSecurityPolicy;
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'ConsultantDataSecurityPolicy')
    DROP SECURITY POLICY security.ConsultantDataSecurityPolicy;
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'ConsultantPersonalPolicy')
    DROP SECURITY POLICY security.ConsultantPersonalPolicy;
GO

-- Drop existing functions if they exist
IF OBJECT_ID('security.fn_ClientSecurityPredicate', 'IF') IS NOT NULL
    DROP FUNCTION security.fn_ClientSecurityPredicate;
IF OBJECT_ID('security.fn_ConsultantSecurityPredicate', 'IF') IS NOT NULL
    DROP FUNCTION security.fn_ConsultantSecurityPredicate;
IF OBJECT_ID('security.fn_ConsultantPersonalPredicate', 'IF') IS NOT NULL
    DROP FUNCTION security.fn_ConsultantPersonalPredicate;
GO

-- Function: ClientSecurityPredicate
CREATE FUNCTION security.fn_ClientSecurityPredicate(@client_id VARCHAR(50))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN 
    SELECT 1 AS result
    WHERE 
        @client_id = USER_NAME()  
        OR USER_NAME() = 'dbo'
        OR IS_MEMBER('ExecutivesRole') = 1
        OR IS_MEMBER('ManagersRole') = 1;
GO

-- Function: ConsultantSecurityPredicate
CREATE FUNCTION security.fn_ConsultantSecurityPredicate(@consultant_id VARCHAR(50))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN 
    SELECT 1 AS result
    WHERE 
        @consultant_id = USER_NAME()
        OR USER_NAME() = 'dbo'
        OR IS_MEMBER('ExecutivesRole') = 1
        OR IS_MEMBER('ManagersRole') = 1;
GO

-- Function: ConsultantPersonalPredicate
CREATE FUNCTION security.fn_ConsultantPersonalPredicate(@consultant_id VARCHAR(50))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN 
    SELECT 1 AS result
    WHERE 
        IS_MEMBER('ConsultantsRole') = 1
        OR USER_NAME() = 'dbo'
        OR IS_MEMBER('ExecutivesRole') = 1
        OR IS_MEMBER('ManagersRole') = 1;
GO

-- Create security policy for client data
CREATE SECURITY POLICY security.ClientDataSecurityPolicy
    ADD FILTER PREDICATE security.fn_ClientSecurityPredicate(client_id)
        ON core.crm_clients,
    ADD FILTER PREDICATE security.fn_ClientSecurityPredicate(client_id)
        ON core.crm_projects,
    ADD FILTER PREDICATE security.fn_ClientSecurityPredicate(client_id)
        ON core.crm_invoices
WITH (STATE = ON);

-- Create security policy for consultant data
CREATE SECURITY POLICY security.ConsultantDataSecurityPolicy
    ADD FILTER PREDICATE security.fn_ConsultantSecurityPredicate(consultant_id)
        ON core.crm_project_assignments,
    ADD FILTER PREDICATE security.fn_ConsultantSecurityPredicate(consultant_id)
        ON core.hcm_timesheets
WITH (STATE = ON);

-- Create security policy for consultant personal data
CREATE SECURITY POLICY security.ConsultantPersonalPolicy
    ADD FILTER PREDICATE security.fn_ConsultantPersonalPredicate(consultant_id)
        ON core.hcm_consultants
WITH (STATE = ON);
GO
