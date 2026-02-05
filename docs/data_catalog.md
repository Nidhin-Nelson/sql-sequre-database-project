# Analytics Layer - Data Catalog

> **Database:** DataSecured  
> **Schema:** analytics

---

## Table of Contents

- [Dimension Tables](#dimension-tables)
  - [dim_clients](#dim_clients)
  - [dim_consultants](#dim_consultants)
  - [dim_projects](#dim_projects)
- [Fact Tables](#fact-tables)
  - [fact_invoices](#fact_invoices)
  - [fact_project_assignments](#fact_project_assignments)

---

## Dimension Tables

### dim_clients

#### Schema

| Column Name | Data Type | Description | Calculation/Source |
|-------------|-----------|-------------|-------------------|
| `client_key` | INT | Surrogate key | `ROW_NUMBER()` |
| `client_id` | VARCHAR(50) | Natural key / Client identifier | `core.crm_clients.client_id` |
| `client_name` | VARCHAR(200) | Client company name | `core.crm_clients.client_name` |
| `industry` | VARCHAR(100) | Industry sector | `core.crm_clients.industry` |
| `country` | VARCHAR(100) | Client country | `core.crm_clients.country` |
| `annual_revenue` | DECIMAL(18,2) | Client's annual revenue | `core.crm_clients.annual_revenue` |
| `contract_value` | DECIMAL(18,2) | Total contract value | `core.crm_clients.contract_value` |
| `tier` | VARCHAR(50) | Client tier (Platinum/Gold/Silver) | `core.crm_clients.tier` |
| `onboarded_date` | DATE | Date client was onboarded | `core.crm_clients.onboarded_date` |
| `months_as_client` | INT | Months since onboarding | `DATEDIFF(MONTH, onboarded_date, GETDATE())` |
| `client_segment` | VARCHAR(50) | Contract value segmentation | Based on contract_value thresholds |
| `revenue_tier` | VARCHAR(50) | Annual revenue segmentation | Based on annual_revenue thresholds |
| `total_projects` | INT | Total number of projects | `COUNT(DISTINCT project_id)` |
| `active_projects` | INT | Number of active projects | `COUNT WHERE status = 'ACTIVE'` |
| `completed_projects` | INT | Number of completed projects | `COUNT WHERE status = 'COMPLETED'` |
| `total_invoices` | INT | Total invoices issued | `COUNT(DISTINCT invoice_id)` |
| `outstanding_invoices` | INT | Unpaid invoices | `COUNT WHERE payment_status != 'PAID'` |
| `outstanding_amount` | DECIMAL(18,2) | Total unpaid amount | `SUM WHERE payment_status != 'PAID'` |

#### Primary Key
- `client_key` (Surrogate)
- `client_id` (Natural)

---

### dim_consultants

#### Schema

| Column Name | Data Type | Description | Calculation/Source |
|-------------|-----------|-------------|-------------------|
| `consultant_key` | INT | Surrogate key | `ROW_NUMBER()` |
| `consultant_id` | VARCHAR(50) | Natural key / Consultant identifier | `core.hcm_consultants.consultant_id` |
| `first_name` | VARCHAR(100) | First name | `core.hcm_consultants.first_name` |
| `last_name` | VARCHAR(100) | Last name | `core.hcm_consultants.last_name` |
| `full_name` | VARCHAR(200) | Full name | `first_name + ' ' + last_name` |
| `email` | VARCHAR(255) | Email address | `core.hcm_consultants.email` |
| `job_title` | VARCHAR(100) | Job title | `core.hcm_consultants.job_title` |
| `security_clearance_level` | VARCHAR(50) | Security clearance | `core.hcm_consultants.security_clearance_level` |
| `hire_date` | DATE | Date hired | `core.hcm_consultants.hire_date` |
| `office_location` | VARCHAR(100) | Office location | `core.hcm_consultants.office_location` |
| `billable_rate` | DECIMAL(18,2) | Hourly billing rate | `core.hcm_consultants.billable_rate` |
| `months_employed` | INT | Months since hire date | `DATEDIFF(MONTH, hire_date, GETDATE())` |
| `seniority_level` | VARCHAR(50) | Seniority tier | Based on years of service |
| `rate_category` | VARCHAR(50) | Rate tier classification | Based on billable_rate |
| `total_projects_assigned` | INT | Total projects assigned | `COUNT(DISTINCT project_id)` |
| `projects_as_lead` | INT | Projects as lead consultant | `COUNT WHERE role = 'Lead'` |

#### Primary Key
- `consultant_key` (Surrogate)
- `consultant_id` (Natural)

---

### dim_projects

#### Schema

| Column Name | Data Type | Description | Calculation/Source |
|-------------|-----------|-------------|-------------------|
| `project_key` | INT | Surrogate key | `ROW_NUMBER()` |
| `project_id` | VARCHAR(50) | Natural key / Project identifier | `core.crm_projects.project_id` |
| `client_id` | VARCHAR(50) | Client foreign key | `core.crm_projects.client_id` |
| `client_name` | VARCHAR(200) | Client name | `core.crm_clients.client_name` |
| `project_name` | VARCHAR(200) | Project name | `core.crm_projects.project_name` |
| `project_type` | VARCHAR(100) | Type of project | `core.crm_projects.project_type` |
| `start_date` | DATE | Project start date | `core.crm_projects.start_date` |
| `end_date` | DATE | Project end date (NULL if ongoing) | `core.crm_projects.end_date` |
| `budget` | DECIMAL(18,2) | Project budget | `core.crm_projects.budget` |
| `status` | VARCHAR(50) | Current status | `core.crm_projects.status` |
| `confidentiality_level` | VARCHAR(50) | Confidentiality classification | `core.crm_projects.confidentiality_level` |
| `project_duration_months` | INT | Duration in months | `DATEDIFF(MONTH, start_date, COALESCE(end_date, GETDATE()))` |
| `days_since_start` | INT | Days since project start | `DATEDIFF(DAY, start_date, GETDATE())` |
| `duration_category` | VARCHAR(50) | Duration classification | Based on project_duration_months |
| `budget_category` | VARCHAR(50) | Budget tier classification | Based on budget amount |
| `team_size` | INT | Number of consultants assigned | `COUNT(DISTINCT consultant_id)` |

#### Primary Key
- `project_key` (Surrogate)
- `project_id` (Natural)

---

## Fact Tables

### fact_invoices

#### Schema

| Column Name | Data Type | Description | Calculation/Source |
|-------------|-----------|-------------|-------------------|
| `invoice_id` | VARCHAR(50) | Invoice identifier | `core.crm_invoices.invoice_id` |
| `client_key` | INT | Client dimension foreign key | `analytics.dim_clients.client_key` |
| `project_key` | INT | Project dimension foreign key | `analytics.dim_projects.project_key` |
| `invoice_date_key` | INT | Invoice date dimension key | Generated from invoice_date |
| `due_date_key` | INT | Due date dimension key | Generated from due_date |
| `paid_date_key` | INT | Paid date dimension key | Generated from paid_date |
| `invoice_date` | DATE | Date invoice was issued | `core.crm_invoices.invoice_date` |
| `due_date` | DATE | Payment due date | `core.crm_invoices.due_date` |
| `paid_date` | DATE | Date payment received | `core.crm_invoices.paid_date` |
| `total_hours` | DECIMAL(10,2) | Hours billed | `core.crm_invoices.total_hours` |
| `total_amount` | DECIMAL(18,2) | Invoice amount | `core.crm_invoices.total_amount` |
| `payment_status` | VARCHAR(50) | Payment status | `core.crm_invoices.payment_status` |
| `days_overdue` | INT | Days past due date | `DATEDIFF(DAY, due_date, COALESCE(paid_date, GETDATE()))` |

#### Primary Key
- `invoice_id`

#### Foreign Keys
- `client_key` → `dim_clients.client_key`
- `project_key` → `dim_projects.project_key`

---

### fact_project_assignments

#### Schema

| Column Name | Data Type | Description | Calculation/Source |
|-------------|-----------|-------------|-------------------|
| `assignment_id` | VARCHAR(50) | Assignment identifier | `core.crm_project_assignments.assignment_id` |
| `consultant_key` | INT | Consultant dimension foreign key | `analytics.dim_consultants.consultant_key` |
| `project_key` | INT | Project dimension foreign key | `analytics.dim_projects.project_key` |
| `start_date_key` | INT | Assignment start date key | Generated from start_date |
| `end_date_key` | INT | Assignment end date key | Generated from end_date |
| `role_on_project` | VARCHAR(50) | Consultant's role | `core.crm_project_assignments.role_on_project` |
| `allocation_percentage` | VARCHAR(10) | Percent allocation | `core.crm_project_assignments.allocation_percentage` |
| `start_date` | DATE | Assignment start date | `core.crm_project_assignments.start_date` |
| `end_date` | DATE | Assignment end date | `core.crm_project_assignments.end_date` |
| `assignment_duration_months` | INT | Duration in months | `DATEDIFF(MONTH, start_date, COALESCE(end_date, GETDATE()))` |
| `is_active_assignment` | BIT | Is currently active (1/0) | `1 if end_date IS NULL OR >= GETDATE()` |
| `allocation_category` | VARCHAR(50) | Allocation tier | Based on allocation_percentage |

#### Primary Key
- `assignment_id`

#### Foreign Keys
- `consultant_key` → `dim_consultants.consultant_key`
- `project_key` → `dim_projects.project_key`

---


