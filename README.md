# Data Warehouse with Row-Level Security

A complete data warehouse implementation featuring **Multi-layered security**, **ETL pipelines**, and **Analytics ready data models** built with SQL Server.

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

## 🔐 Security Features

### Multi-Layer Security Model

| Security Layer | Implementation | Purpose |
|----------------|----------------|---------|
| **Row-Level Security (RLS)** | SQL Server security policies | Automatically filters data based on logged-in user |
| **Role-Based Access Control** | Database roles + permissions | Groups users by function (Client/Consultant/Manager/Executive) |
| **Column-Level Security** | DENY permissions on columns | Hides sensitive fields (billable rates, contract values) |
| **Security Views** | Filtered views per role | Pre-built queries for each user type |


### User Roles & Access

| Role | Can Access | Cannot Access | Data Scope |
|------|-----------|---------------|------------|
| **Client** | Own projects, invoices, status | Other clients, consultant rates | Filtered by client_id |
| **Consultant** | Own assignments, timesheets | Billable rates, client financials | Filtered by consultant_id |
| **Manager** | All projects, team data, analytics | N/A | Full access |
| **Executive** | Everything (unfiltered) | N/A | Full access |


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

## 📄 License

This project is licensed under the MIT License

---

**Note:** This is a portfolio project demonstrating data warehouse and security concepts. All data is synthetic and for educational purposes only.
