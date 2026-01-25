# Naming Conventions
---
This document defines the official naming standards for the project.  
These conventions are mandatory and are used consistently across all layers.
---
## Table of Contents
1. Core Principles
2. Table Naming
   * Raw Layer
   * Core Layer
   * Analytics Layer
   * Security Layer
3. Column Naming
   * Technical Columns
4. Stored Procedures
5. Additional Conventions
---
## Core Principles
The following principles apply to all database objects:
* **Format**: snake_case using lowercase letters and underscores only
* **Language**: English only
* **Reserved Words**: SQL reserved keywords must never be used
* **Consistency**: Naming must be predictable and repeatable across layers
* **Clarity**: Names should be self-documenting and unambiguous
---
## Table Naming
### Raw Layer
Raw layer tables represent data ingested directly from source systems without business logic. Source system naming must be preserved exactly to ensure traceability.

**Pattern**
`<source_system>_<entity>`

**Examples**
* `crm_clients`
* `crm_projects`
* `crm_invoices`
* `hcm_consultants`
* `hcm_timesheets`
---
### Core Layer
Core layer tables represent cleaned, standardized, and conformed data. These tables remain source aligned and do not yet include business aggregations.

**Pattern**
`<source_system>_<entity>`

**Examples**
* `crm_clients`
* `crm_projects`
* `crm_invoices`
* `hcm_consultants`
* `hcm_timesheets`
---
### Analytics Layer
Analytics layer tables are business ready and designed for analytical querying. Tables follow a category based prefix system and contain modeled facts and dimensions.

**Pattern**
`<category>_<entity>`

**Categories**
| Prefix  | Purpose       | Examples                           |
| ------- | ------------- | ---------------------------------- |
| dim_    | Dimension     | dim_customer, dim_consultant       |
| fact_   | Fact          | fact_timesheets, fact_billing      |
| bridge_ | Bridge Table  | bridge_project_team                |
| report_ | Reporting     | report_monthly_utilization         |
---
### Security Layer
Security layer objects manage access control, auditing, and data governance.

**Pattern**
`sec_<purpose>`

**Examples**
* `sec_user_roles`
* `sec_access_policies`
* `sec_audit_log`
* `sec_rls_functions`
---
## Column Naming
### Technical Columns
System generated metadata columns used for data warehouse operations and auditing.

**Pattern**
`dwh_<purpose>`

**Examples**
* `dwh_load_date` - Timestamp when record was loaded
* `dwh_batch_id` - ETL batch identifier
* `dwh_source_system` - Origin system identifier
* `dwh_created_by` - User or process that created record
* `dwh_updated_date` - Last modification timestamp
---
## Stored Procedures
Stored procedures used for data loading and transformation.

**Pattern**
`sp_load_<layer>_<entity>`

**Examples**
* `sp_load_raw_crm`
* `sp_load_core_clients`
* `sp_load_analytics_dimensions`
* `sp_load_security_audit`

**Utility Procedures**
* `sp_audit_log_insert`
* `sp_data_quality_check`
* `sp_refresh_rls_policies`
---
## Additional Conventions

### View Naming
Views in analytics and security layers.

**Pattern**
`vw_<purpose>`

**Examples**
* `vw_consultant_dashboard`
* `vw_project_performance`
* `vw_client_360`
* `vw_timesheet_secure`

### Function Naming
User-defined functions for calculations and row-level security.

**Pattern**
`fn_<purpose>`

**Examples**
* `fn_timesheet_rls_filter`
* `fn_calculate_utilization`
* `fn_project_access_control`
