/*
-----------------------------------------------------------
Stored Procedure - Load Raw Layer
-----------------------------------------------------------
Purpose: 
- Creates raw.load_raw stored procedure that:
- Truncates ALL raw tables 
- BULK INSERTs raw CSV data from source 
- Times each table load with start/end timestamps

Usage Example:
- EXEC [raw].load_raw;

Parameters:
- None, This stored procedure does not accept any parameters or return any values.

Warning: 
- Empties ALL raw tables before loading

-----------------------------------------------------------

*/


CREATE OR ALTER PROCEDURE raw.load_raw AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY

	SET @batch_start_time = GETDATE();
	PRINT '============================================================';
	PRINT 'Loading Raw Layer';
	PRINT '============================================================';

	PRINT '-----------------------------------------------------------';
	PRINT 'Loading CRM Tables';
	PRINT '-----------------------------------------------------------';

--CRM CLIENTS
	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: raw.crm_clients';

	TRUNCATE TABLE raw.crm_clients;

	PRINT '+ Inserting Into Table: raw.crm_clients';

	BULK INSERT [raw].[crm_clients]
	FROM 'C:\temp\crm_clients.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';
	
--CRM PROJECTS
	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: raw.crm_projects';

	TRUNCATE TABLE raw.crm_projects;

	PRINT '+ Inserting Into Table: raw.crm_projects';

	BULK INSERT [raw].[crm_projects]
	FROM 'C:\temp\crm_projects.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

--CRM PROJECT ASSIGNMENTS
	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: raw.crm_project_assignments';

	TRUNCATE TABLE [raw].[crm_project_assignments];

	PRINT '+ Inserting Into Table: raw.crm_project_assignments';

	BULK INSERT [raw].[crm_project_assignments]
	FROM 'C:\temp\crm_project_assignments.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

--CRM INVOICES
	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: raw.crm_invoices';

	TRUNCATE TABLE [raw].[crm_invoices];

	PRINT '+ Inserting Into Table: raw.crm_invoices';

	BULK INSERT [raw].[crm_invoices]
	FROM 'C:\temp\crm_invoices.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

	PRINT '-----------------------------------------------------------';
	PRINT 'Loading HCM Tables';
	PRINT '-----------------------------------------------------------';

--HCM CONSULTANTS
	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: raw.hcm_consultants';

	TRUNCATE TABLE [raw].[hcm_consultants];

	PRINT '+ Inserting Into Table: raw.hcm_consultants';

	BULK INSERT [raw].[hcm_consultants]
	FROM 'C:\temp\hcm_consultants.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

--HCM TIMESHEETS
	SET @start_time = GETDATE();
	PRINT '+ Truncating Table: raw.hcm_timesheets';

	TRUNCATE TABLE [raw].[hcm_timesheets];

	PRINT '+ Inserting Into Table: raw.hcm_timesheets';

	BULK INSERT [raw].[hcm_timesheets]
	FROM 'C:\temp\hcm_timesheets.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------------------------------------------------';

	SET @batch_end_time = GETDATE();
		PRINT '======================================================='
		PRINT 'Loading Raw Layer is Completed';
        PRINT '+ Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '======================================================='

	END TRY
	BEGIN CATCH
		PRINT '========================================================='
		PRINT 'Error Occured During Loading Raw Layer'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================='
	END CATCH
END;

