# Data Warehouse with Row-Level Security

A complete data warehouse implementation featuring **multi-layered security**, **ETL pipelines**, and **analytics-ready data models** built with SQL Server.

---

## 🎯 Project Highlights

This project demonstrates:

✅ **Enterprise Data Architecture** - 3-layer warehouse design (Raw → Core → Analytics)  
✅ **Row-Level Security (RLS)** - Automatic data filtering based on user roles  
✅ **Role-Based Access Control** - 4 distinct user roles with granular permissions  
✅ **ETL Pipeline Development** - Automated data transformation and loading  
✅ **Star Schema Design** - Optimized dimensional model for analytics  
✅ **Data Quality Validation** - Comprehensive testing and validation scripts

---

## 🏗️ Architecture Overview

### Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  SECURITY LAYER PROTECTION                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   │
│  │   CLIENTS    │   │ CONSULTANTS  │   │   MANAGERS   │   │
│  │              │   │              │   │              │   │
│  │ • Own data   │   │ • Own data   │   │ • All data   │   │
│  │   only       │   │   only       │   │              │   │
│  └──────┬───────┘   └──────┬───────┘   └──────┬───────┘   │
│         │                  │                  │            │
│         ▼                  ▼                  ▼            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          ROW-LEVEL SECURITY FILTERING                │  │
│  │                                                      │  │
│  │  Automatic WHERE clause applied to ALL queries      │  │
│  └──────────────────────────────────────────────────────┘  │
│         │                  │                  │            │
│         ▼                  ▼                  ▼            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              PROTECTED CORE TABLES                   │  │
│  │  • crm_clients    • crm_invoices                     │  │
│  │  • crm_projects   • hcm_consultants                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Features

### Multi-Layer Security Model

| Security Layer | Implementation | Purpose |
|----------------|----------------|---------|
| **Row-Level Security (RLS)** | SQL Server security policies | Automatically filters data based on logged-in user |
| **Role-Based Access Control** | Database roles + permissions | Groups users by function (Client/Consultant/Manager/Executive) |
| **Column-Level Security** | DENY permissions on columns | Hides sensitive fields (billable rates, contract values) |
| **Security Views** | Filtered views per role | Pre-built queries for each user type |

### User Roles & Access Matrix

| Role | Can Access | Cannot Access | Data Scope |
|------|-----------|---------------|------------|
| **Client** | Own projects, invoices, status | Other clients, consultant rates | Filtered by client_id |
| **Consultant** | Own assignments, timesheets | Billable rates, client financials | Filtered by consultant_id |
| **Manager** | All projects, team data, analytics | N/A | Full access |
| **Executive** | Everything (unfiltered) | N/A | Full access |

### How RLS Works

```sql
-- Client C001 queries the invoices table
SELECT * FROM core.crm_invoices;

-- SQL Server automatically applies RLS filter:
-- WHERE client_id = 'C001'

-- Result: Only sees their own invoices (not C002, C003, etc.)
```

**Key Benefits:**
- ✅ Security enforced at database level (cannot be bypassed)
- ✅ Automatic filtering on ALL queries
- ✅ No application-side filtering required
- ✅ Defense-in-depth security model

---

## 📊 Data Model

### Core Tables (Source of Truth)

**CRM System:**
- `crm_clients` - Client master data
- `crm_projects` - Project information
- `crm_invoices` - Billing and payments
- `crm_project_assignments` - Consultant assignments

**HCM System:**
- `hcm_consultants` - Employee master data
- `hcm_timesheets` - Time tracking

### Analytics Layer (Star Schema)

**Dimensions:**
- `dim_clients` - Client dimension with metrics
- `dim_consultants` - Consultant dimension with KPIs
- `dim_projects` - Project dimension with status

**Facts:**
- `fact_invoices` - Invoice transactions
- `fact_project_assignments` - Assignment details


---

## 📁 Repository Structure

```
data-warehouse-security/
│
├── datasets/
│   ├── source_crm/              # CRM system CSV files
│   │   ├── crm_clients.csv
│   │   ├── crm_projects.csv
│   │   └── crm_invoices.csv
│   └── source_hcm/              # HCM system CSV files
│       ├── hcm_consultants.csv
│       └── hcm_timesheets.csv
│
├── docs/
│   ├── data_catalog.md          # Analytics data catalog
│   └── naming_conventions.md    # Naming standards
│
├── scripts/
│   ├── init_database.sql        # Database initialization
│   ├── raw/                     # Raw layer scripts
│   ├── core/                    # Core layer scripts
│   ├── analytics/               # Analytics layer scripts
│   └── security/                # Security implementation
│
├── test/
│   ├── drop_roles_analytics.sql
│   ├── quality_checks_core.sql              # Core layer quality checks
│   ├── quality_checks_analytics.sql         # Analytics layer quality checks
│   └── quality_checks_security.sql          # Security testing
│
├── .gitignore
├── LICENSE                      # MIT License
└── README.md
```

## 💻 Key SQL Techniques Used

### Data Transformation
- `CASE` statements for data categorization
- `TRY_CAST` for safe type conversion
- `COALESCE` for NULL handling
- `DATEDIFF` for date calculations

### Performance Optimization
- Indexed views for frequently accessed data
- Partitioning strategies for large tables
- Query optimization with execution plans

### Security Implementation
- Security predicate functions
- `CREATE SECURITY POLICY` statements
- Role-based permission management
- `EXECUTE AS` for testing

---

## 📈 Business Value

### Consulting Firm Use Case

This data warehouse enables:

**For Clients:**
- Self-service access to project status
- Real-time invoice tracking
- Payment history visibility

**For Consultants:**
- View their project assignments
- Track hours worked
- See project details

**For Managers:**
- Team performance monitoring
- Project budget tracking
- Resource allocation insights

**For Executives:**
- Company-wide analytics
- Revenue reporting
- Strategic decision support

---

## 📚 Skills Demonstrated

**Database Development:**
- SQL Server development
- Stored procedures
- Complex queries with CTEs
- Window functions

**Data Architecture:**
- Multi-layer warehouse design
- Star schema modeling
- ETL pipeline development

**Security:**
- Row-Level Security (RLS)
- Role-Based Access Control (RBAC)
- Column-level permissions
- Security testing

**Best Practices:**
- Version control with Git
- Comprehensive documentation
- Data quality validation
- Idempotent scripts

---

## 🛠️ Technologies

| Category | Technology |
|----------|-----------|
| **Database** | SQL Server 2019+ |
| **IDE** | SQL Server Management Studio (SSMS) |
| **Version Control** | Git / GitHub |
| **Documentation** | Markdown |

---

## 🎓 Learning Outcomes

Through this project, I gained expertise in:

✅ **Enterprise Data Warehouse Design** - Multi-layer architecture implementation  
✅ **Advanced Security** - Row-level and role-based security  
✅ **ETL Development** - Building robust data pipelines  
✅ **SQL Mastery** - Complex queries and optimization  
✅ **Data Modeling** - Star schema for analytics  
✅ **Best Practices** - Industry standards and documentation  

---

## 📄 License

This project is licensed under the MIT License

---

**Note:** This is a portfolio project demonstrating data warehouse and security concepts. All data is synthetic and for educational purposes only.
