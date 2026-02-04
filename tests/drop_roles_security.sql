IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ClientRole' AND type = 'R')
BEGIN
    IF IS_ROLEMEMBER('ClientRole', 'CLI-5001') = 1 ALTER ROLE [ClientRole] DROP MEMBER [CLI-5001];
    IF IS_ROLEMEMBER('ClientRole', 'CLI-5002') = 1 ALTER ROLE [ClientRole] DROP MEMBER [CLI-5002];
END

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ConsultantRole' AND type = 'R')
BEGIN
    IF IS_ROLEMEMBER('ConsultantRole', 'CON-1008') = 1 ALTER ROLE [ConsultantRole] DROP MEMBER [CON-1008];
    IF IS_ROLEMEMBER('ConsultantRole', 'CON-1009') = 1 ALTER ROLE [ConsultantRole] DROP MEMBER [CON-1009];
END

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ManagerRole' AND type = 'R')
BEGIN
    IF IS_ROLEMEMBER('ManagerRole', 'CON-1003') = 1 ALTER ROLE [ManagerRole] DROP MEMBER [CON-1003];
END

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ExecutiveRole' AND type = 'R')
BEGIN
    IF IS_ROLEMEMBER('ExecutiveRole', 'CON-1013') = 1 ALTER ROLE [ExecutiveRole] DROP MEMBER [CON-1013];
END
GO

-- 2. Drop the Roles
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ClientRole' AND type = 'R') DROP ROLE [ClientRole];
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ConsultantRole' AND type = 'R') DROP ROLE [ConsultantRole];
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ManagerRole' AND type = 'R') DROP ROLE [ManagerRole];
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ExecutiveRole' AND type = 'R') DROP ROLE [ExecutiveRole];

-- 3. Drop the Users
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CLI-5001') DROP USER [CLI-5001];
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CLI-5002') DROP USER [CLI-5002];
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CON-1008') DROP USER [CON-1008];
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CON-1009') DROP USER [CON-1009];
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CON-1003') DROP USER [CON-1003];
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CON-1013') DROP USER [CON-1013];
GO
