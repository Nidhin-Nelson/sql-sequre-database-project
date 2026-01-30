/*
-------------------------------------------------------------
Stored Procedure - Load Core Layer
-------------------------------------------------------------
Purpose:
- Creates core.load_core stored procedure that:
- Truncates ALL core tables
- Loads cleaned/transformed data from raw tables into core
- Times each table load with start/end timestamps

Usage:
- EXEC [core].load_core;

Parameters:
- None

Warning:
- Empties ALL core tables before loading
-------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE [core].load_core AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY

	SET @batch_start_time = GETDATE();
	PRINT '============================================================';
	PRINT 'Loading Core Layer';
	PRINT '============================================================';

	PRINT '-----------------------------------------------------------';
	PRINT 'Loading CRM Tables';
	PRINT '-----------------------------------------------------------';


	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: core.crm_clients';

	TRUNCATE TABLE core.crm_clients;

	PRINT '+ Inserting Into Table: core.crm_clients';

	INSERT INTO core.crm_clients (
		client_id,
		client_name,
		industry,
		country,
		annual_revenue,
		contract_value,
		tier,
		onboarded_date )
	SELECT
		TRIM(client_id) AS client_id,
		TRIM(client_name) AS client_name,
		TRIM(UPPER(industry)) AS industry, 
		TRIM(UPPER(country)) AS country,  
		CASE 
			-- 1. Check if it's numeric and greater than 0
			WHEN TRY_CAST(annual_revenue AS DECIMAL(18,2)) > 0 
				THEN TRY_CAST(annual_revenue AS DECIMAL(18,2))
            
			-- 2. Handle zero or negative values 
			WHEN TRY_CAST(annual_revenue AS DECIMAL(18,2)) <= 0 
				THEN NULL 
			ELSE NULL
        END AS annual_revenue,

		CASE 
			-- 1. Check if it's numeric and greater than 0
			WHEN TRY_CAST(contract_value AS DECIMAL(18,2)) > 0 
				THEN TRY_CAST(contract_value AS DECIMAL(18,2))
            
			-- 2. Handle zero or negative values 
			WHEN TRY_CAST(contract_value AS DECIMAL(18,2)) <= 0 
				THEN NULL
			ELSE NULL
        END AS contract_value,

		CASE 
			WHEN TRIM(UPPER(tier)) = 'P' THEN 'Platinum'
			WHEN TRIM(UPPER(tier)) = 'G' THEN 'Gold'
			WHEN TRIM(UPPER(tier)) = 'S' THEN 'Silver'
			ELSE 'N/A'
		END AS tier, -- Change tier to readable format
		onboarded_date
	FROM (
		SELECT *,
			ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY onboarded_date DESC) AS flag
		FROM raw.crm_clients
		WHERE client_id IS NOT NULL
	)t
	WHERE flag = 1; -- Select the most recent record per customer

	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: core.crm_projects';

	TRUNCATE TABLE core.crm_projects;

	PRINT '+ Inserting Into Table: core.crm_projects';

	INSERT INTO core.crm_projects (
		project_id,
		client_id,
		project_name,
		project_type,
		start_date,
		end_date,
		budget,
		status,
		confidentiality_level )
	SELECT
		TRIM(project_id) AS project_id,
		TRIM(client_id) AS client_id,
		TRIM(UPPER(project_name)),
		TRIM(UPPER(project_type)),
		start_date,
		end_date,

		CASE 
			-- 1. Check if it's numeric and greater than 0
			WHEN TRY_CAST(budget AS DECIMAL(18,2)) > 0 
				THEN TRY_CAST(budget AS DECIMAL(18,2))
            
			-- 2. Handle zero or negative values 
			WHEN TRY_CAST(budget AS DECIMAL(18,2)) <= 0 
				THEN NULL
			ELSE NULL
        END AS budget,

		TRIM(UPPER(status)),
		TRIM(UPPER(confidentiality_level))
	FROM raw.crm_projects;

	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: core.crm_project_assignments';

	TRUNCATE TABLE core.crm_project_assignments;

	PRINT '+ Inserting Into Table: core.crm_project_assignments';

	INSERT INTO core.crm_project_assignments (
		assignment_id,
		project_id,
		consultant_id,
		role_on_project,
		allocation_percentage,
		start_date,
		end_date )
	SELECT 
		TRIM(assignment_id) AS assignment_id,
		TRIM(project_id) AS project_id,
		TRIM(consultant_id) AS consultant_id,
		CASE 
			WHEN TRIM(UPPER(role_on_project)) = 'L' THEN 'Lead'
			WHEN TRIM(UPPER(role_on_project)) = 'J' THEN 'Junior'
			WHEN TRIM(UPPER(role_on_project)) = 'S' THEN 'Senior'
			WHEN TRIM(UPPER(role_on_project)) = 'A' THEN 'Assistant'
			ELSE 'N/A'
		END AS role_on_project, -- Change role_on_project to readable format
		TRIM(allocation_percentage) AS allocation_percentage,
		start_date,
		end_date
	FROM raw.crm_project_assignments;

	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: core.crm_invoices';

	TRUNCATE TABLE core.crm_invoices;

	PRINT '+ Inserting Into Table: core.crm_invoices';

	INSERT INTO core.crm_invoices (
		invoice_id,
		client_id,
		project_id,
		invoice_date,
		due_date,
		total_hours,
		total_amount,
		payment_status,
		paid_date )
	SELECT
		TRIM(UPPER(invoice_id)),
		TRIM(UPPER(client_id)),
		TRIM(UPPER(project_id)),
		invoice_date,
		due_date,

		CASE 
			-- Check if it's a valid number
			WHEN TRY_CAST(total_hours AS INT) IS NULL THEN NULL
			-- If value seems like minutes, convert to hours
			WHEN TRY_CAST(total_hours AS INT) > 10000 THEN TRY_CAST(total_hours AS INT) / 60.0
			ELSE TRY_CAST(total_hours AS INT)
        END AS total_hours,

		CASE 
			-- 1. Check if it's numeric and greater than 0
			WHEN TRY_CAST(total_amount AS DECIMAL(18,2)) > 0 
				THEN TRY_CAST(total_amount AS DECIMAL(18,2))
            
			-- 2. Handle zero or negative values 
			WHEN TRY_CAST(total_amount AS DECIMAL(18,2)) <= 0 
				THEN NULL
			ELSE NULL
        END AS total_amount,
		TRIM(UPPER(payment_status)),
		paid_date

	FROM raw.crm_invoices;

	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

	PRINT '-----------------------------------------------------------';
	PRINT 'Loading HCM Tables';
	PRINT '-----------------------------------------------------------';

	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: core.hcm_consultants';

	TRUNCATE TABLE core.hcm_consultants;

	PRINT '+ Inserting Into Table: core.hcm_consultants';

	INSERT INTO core.hcm_consultants (
		consultant_id,
		first_name,
		last_name,
		email,
		job_title,
		security_clearance_level,
		hire_date,
		office_location,
		billable_rate )

	SELECT
		TRIM(UPPER(consultant_id)),
		TRIM(first_name),
		TRIM(last_name),

		CASE 
			-- Must have @ and . 
			WHEN LOWER(TRIM(email)) LIKE '%@%.%' 
				AND LOWER(TRIM(email)) NOT LIKE '%..%'
				AND LOWER(TRIM(email)) NOT LIKE '% %'
				AND LEN(TRIM(email)) > 5
				AND LEN(TRIM(email)) < 255
				-- Must have characters before and after @
				AND CHARINDEX('@', TRIM(email)) > 1
				AND CHARINDEX('@', TRIM(email)) < LEN(TRIM(email))
				-- No @ at start or end
				AND TRIM(email) NOT LIKE '@%' 
				AND TRIM(email) NOT LIKE '%@'
			THEN LOWER(TRIM(email))
			ELSE NULL
		END AS email,
		TRIM(UPPER(job_title)),

		CASE TRY_CAST(security_clearance_level AS INT)
			WHEN 1 THEN 'Intern'
			WHEN 2 THEN 'Standard'
			WHEN 3 THEN 'Confidential'
			WHEN 4 THEN 'Secret'
			WHEN 5 THEN 'Top Boss'
			ELSE NULL
        END AS security_clearance_level,
		hire_date,
		TRIM(UPPER(office_location)),
		CASE 
			-- 1. Check if it's numeric and greater than 0
			WHEN TRY_CAST(billable_rate AS DECIMAL(18,2)) > 0 
				THEN TRY_CAST(billable_rate AS DECIMAL(18,2))
            
			-- 2. Handle zero or negative values 
			WHEN TRY_CAST(billable_rate AS DECIMAL(18,2)) <= 0 
				THEN NULL
			ELSE NULL
		END AS billable_rate
	FROM raw.hcm_consultants;

	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: core.hcm_timesheets';

	TRUNCATE TABLE core.hcm_timesheets;

	PRINT '+ Inserting Into Table: core.hcm_timesheets';

	INSERT INTO core.hcm_timesheets (
		timesheet_id,
		consultant_id,
		project_id,
		work_date,
		hours_worked,
		billable,
		activity_description,
		submitted_date )
	SELECT
		TRIM(UPPER(timesheet_id)),
		TRIM(UPPER(consultant_id)),
		TRIM(UPPER(project_id)),
		work_date,
		CASE
			-- Must be valid decimal
			WHEN TRY_CAST(hours_worked AS DECIMAL(5,2)) IS NULL THEN NULL
			-- Must be positive 
			WHEN TRY_CAST(hours_worked AS DECIMAL(5,2)) BETWEEN 0.01 AND 24
				THEN TRY_CAST(hours_worked AS DECIMAL(5,2))
			ELSE NULL
		END AS hours_worked,
		CASE 
			WHEN UPPER(TRIM(billable)) IN ('YES', 'Y', '1', 'TRUE') THEN 'Yes'
			WHEN UPPER(TRIM(billable)) IN ('NO', 'N', '0', 'FALSE') THEN 'No'
			ELSE NULL
		END AS billable,
		TRIM(activity_description),
		submitted_date 
	FROM raw.hcm_timesheets;


	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';
	
	SET @batch_end_time = GETDATE();
		PRINT '======================================================='
		PRINT 'Loading Core Layer is Completed';
        PRINT '+ Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '======================================================='

	END TRY
	BEGIN CATCH
		PRINT '========================================================='
		PRINT 'Error Occured During Loading Core Layer'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================='
	END CATCH
END;
