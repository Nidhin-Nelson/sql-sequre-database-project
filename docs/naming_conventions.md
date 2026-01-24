# Naming Conventions

---

This document defines the official naming standards for all data warehouse objects including schemas, tables, views, columns, and stored procedures. These conventions are mandatory and are used consistently across all layers of the data warehouse.

---

## Table of Contents

1. Core Principles
2. Table Naming

   * Raw Layer
   * Core Layer
   * Analytics Layer
   * Semantic Layer
3. Column Naming

   * Surrogate Keys
   * Technical Columns
4. Stored Procedures

---

## Core Principles

The following principles apply to all database objects:

* **Format**: snake_case using lowercase letters and underscores only
* **Language**: English only
* **Reserved Words**: SQL reserved keywords must never be used
* **Consistency**: Naming must be predictable and repeatable across layers

---

## Table Naming

### Raw Layer

Raw layer tables represent data ingested directly from source systems without business logic. Source system naming must be preserved exactly to ensure traceability.

**Pattern**
`<source_system>_<entity>`

**Examples**

* `ecom_customers`
* `ops_inventory`

---

### Core Layer

Core layer tables represent cleaned, standardized, and conformed data. These tables remain source aligned and do not yet include business aggregations.

**Pattern**
`<source_system>_<entity>`

**Examples**

* `ecom_customers`
* `ops_inventory`

---

### Analytics Layer

Analytics layer tables are business ready and designed for analytical querying. Tables follow a category based prefix system and contain modeled facts and dimensions.

**Pattern**
`<category>_<entity>`

**Categories**

| Prefix  | Purpose   | Examples                    |
| ------- | --------- | --------------------------- |
| dim_    | Dimension | dim_customers, dim_products |
| fact_   | Fact      | fact_sales                  |
| report_ | Reporting | report_monthly_sales        |

---

### Semantic Layer

Semantic layer objects expose curated, consumption ready views for business users. These objects abstract joins and enforce consistent business logic.

**Pattern**
`<business_subject>_<description>`

**Examples**

* `sales_summary`
* `inventory_status`

---

## Column Naming

### Surrogate Keys

Primary keys generated within the data warehouse for dimension tables.

**Pattern**
`<entity>_key`

**Example**

* `customer_key`

---

### Technical Columns

System generated metadata columns used for data warehouse operations and auditing.

**Pattern**
`dwh_<purpose>`

**Examples**

* `dwh_load_date`
* `dwh_batch_id`

---

## Stored Procedures

Stored procedures used for data loading and transformation.

**Pattern**
`load_<layer>`

**Examples**

* `load_raw`
* `load_core`
* `load_analytics`
* `load_semantic`

---

This document serves as the authoritative reference for naming standards and must be followed for all current and future development within the data warehouse.
