USE AutoLot;
GO

IF COL_LENGTH('dbo.Users', 'UserName') IS NULL
	ALTER TABLE dbo.Users ADD UserName nvarchar(254) NULL;
IF COL_LENGTH('dbo.Users', 'NormalizedUserName') IS NULL
	ALTER TABLE dbo.Users ADD NormalizedUserName nvarchar(254) NULL;
IF COL_LENGTH('dbo.Users', 'NormalizedEmail') IS NULL
	ALTER TABLE dbo.Users ADD NormalizedEmail nvarchar(254) NULL;
IF COL_LENGTH('dbo.Users', 'EmailConfirmed') IS NULL
	ALTER TABLE dbo.Users ADD EmailConfirmed bit NOT NULL CONSTRAINT DF_Users_EmailConfirmed DEFAULT (0);
IF COL_LENGTH('dbo.Users', 'SecurityStamp') IS NULL
	ALTER TABLE dbo.Users ADD SecurityStamp nvarchar(max) NULL;
IF COL_LENGTH('dbo.Users', 'ConcurrencyStamp') IS NULL
	ALTER TABLE dbo.Users ADD ConcurrencyStamp nvarchar(max) NULL;
IF COL_LENGTH('dbo.Users', 'PhoneNumberConfirmed') IS NULL
	ALTER TABLE dbo.Users ADD PhoneNumberConfirmed bit NOT NULL CONSTRAINT DF_Users_PhoneNumberConfirmed DEFAULT (0);
IF COL_LENGTH('dbo.Users', 'TwoFactorEnabled') IS NULL
	ALTER TABLE dbo.Users ADD TwoFactorEnabled bit NOT NULL CONSTRAINT DF_Users_TwoFactorEnabled DEFAULT (0);
IF COL_LENGTH('dbo.Users', 'LockoutEnd') IS NULL
	ALTER TABLE dbo.Users ADD LockoutEnd datetimeoffset NULL;
IF COL_LENGTH('dbo.Users', 'LockoutEnabled') IS NULL
	ALTER TABLE dbo.Users ADD LockoutEnabled bit NOT NULL CONSTRAINT DF_Users_LockoutEnabled DEFAULT (0);
IF COL_LENGTH('dbo.Users', 'AccessFailedCount') IS NULL
	ALTER TABLE dbo.Users ADD AccessFailedCount int NOT NULL CONSTRAINT DF_Users_AccessFailedCount DEFAULT (0);
GO

IF OBJECT_ID('dbo.AspNetRoles', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.AspNetRoles (
		Id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_AspNetRoles PRIMARY KEY,
		Name nvarchar(256) NULL,
		NormalizedName nvarchar(256) NULL,
		ConcurrencyStamp nvarchar(max) NULL
	);
END;

IF OBJECT_ID('dbo.AspNetUserClaims', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.AspNetUserClaims (
		Id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_AspNetUserClaims PRIMARY KEY,
		UserId int NOT NULL,
		ClaimType nvarchar(max) NULL,
		ClaimValue nvarchar(max) NULL,
		CONSTRAINT FK_AspNetUserClaims_Users_UserId FOREIGN KEY (UserId) REFERENCES dbo.Users(UserID) ON DELETE CASCADE
	);
END;

IF OBJECT_ID('dbo.AspNetUserLogins', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.AspNetUserLogins (
		LoginProvider nvarchar(128) NOT NULL,
		ProviderKey nvarchar(128) NOT NULL,
		ProviderDisplayName nvarchar(max) NULL,
		UserId int NOT NULL,
		CONSTRAINT PK_AspNetUserLogins PRIMARY KEY (LoginProvider, ProviderKey),
		CONSTRAINT FK_AspNetUserLogins_Users_UserId FOREIGN KEY (UserId) REFERENCES dbo.Users(UserID) ON DELETE CASCADE
	);
END;

IF OBJECT_ID('dbo.AspNetUserRoles', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.AspNetUserRoles (
		UserId int NOT NULL,
		RoleId int NOT NULL,
		CONSTRAINT PK_AspNetUserRoles PRIMARY KEY (UserId, RoleId),
		CONSTRAINT FK_AspNetUserRoles_Users_UserId FOREIGN KEY (UserId) REFERENCES dbo.Users(UserID) ON DELETE CASCADE,
		CONSTRAINT FK_AspNetUserRoles_AspNetRoles_RoleId FOREIGN KEY (RoleId) REFERENCES dbo.AspNetRoles(Id) ON DELETE CASCADE
	);
END;

IF OBJECT_ID('dbo.AspNetRoleClaims', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.AspNetRoleClaims (
		Id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_AspNetRoleClaims PRIMARY KEY,
		RoleId int NOT NULL,
		ClaimType nvarchar(max) NULL,
		ClaimValue nvarchar(max) NULL,
		CONSTRAINT FK_AspNetRoleClaims_AspNetRoles_RoleId FOREIGN KEY (RoleId) REFERENCES dbo.AspNetRoles(Id) ON DELETE CASCADE
	);
END;

IF OBJECT_ID('dbo.AspNetUserTokens', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.AspNetUserTokens (
		UserId int NOT NULL,
		LoginProvider nvarchar(128) NOT NULL,
		Name nvarchar(128) NOT NULL,
		Value nvarchar(max) NULL,
		CONSTRAINT PK_AspNetUserTokens PRIMARY KEY (UserId, LoginProvider, Name),
		CONSTRAINT FK_AspNetUserTokens_Users_UserId FOREIGN KEY (UserId) REFERENCES dbo.Users(UserID) ON DELETE CASCADE
	);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.AspNetRoles') AND name = 'RoleNameIndex')
	CREATE UNIQUE INDEX RoleNameIndex ON dbo.AspNetRoles(NormalizedName) WHERE NormalizedName IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.Users') AND name = 'UserNameIndex')
	CREATE UNIQUE INDEX UserNameIndex ON dbo.Users(NormalizedUserName) WHERE NormalizedUserName IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.Users') AND name = 'EmailIndex')
	CREATE INDEX EmailIndex ON dbo.Users(NormalizedEmail);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.AspNetUserClaims') AND name = 'IX_AspNetUserClaims_UserId')
	CREATE INDEX IX_AspNetUserClaims_UserId ON dbo.AspNetUserClaims(UserId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.AspNetUserLogins') AND name = 'IX_AspNetUserLogins_UserId')
	CREATE INDEX IX_AspNetUserLogins_UserId ON dbo.AspNetUserLogins(UserId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.AspNetUserRoles') AND name = 'IX_AspNetUserRoles_RoleId')
	CREATE INDEX IX_AspNetUserRoles_RoleId ON dbo.AspNetUserRoles(RoleId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.AspNetRoleClaims') AND name = 'IX_AspNetRoleClaims_RoleId')
	CREATE INDEX IX_AspNetRoleClaims_RoleId ON dbo.AspNetRoleClaims(RoleId);
GO

UPDATE dbo.Users
SET UserName = COALESCE(UserName, Email),
	NormalizedUserName = COALESCE(NormalizedUserName, UPPER(Email)),
	NormalizedEmail = COALESCE(NormalizedEmail, UPPER(Email)),
	SecurityStamp = COALESCE(SecurityStamp, CONVERT(nvarchar(36), NEWID())),
	ConcurrencyStamp = COALESCE(ConcurrencyStamp, CONVERT(nvarchar(36), NEWID()));

IF NOT EXISTS (SELECT 1 FROM dbo.AspNetRoles WHERE NormalizedName = 'CUSTOMER')
	INSERT dbo.AspNetRoles(Name, NormalizedName, ConcurrencyStamp)
	VALUES ('Customer', 'CUSTOMER', CONVERT(nvarchar(36), NEWID()));
IF NOT EXISTS (SELECT 1 FROM dbo.AspNetRoles WHERE NormalizedName = 'EMPLOYEE')
	INSERT dbo.AspNetRoles(Name, NormalizedName, ConcurrencyStamp)
	VALUES ('Employee', 'EMPLOYEE', CONVERT(nvarchar(36), NEWID()));

IF COL_LENGTH('dbo.Users', 'Role') IS NOT NULL
BEGIN
	EXEC(N'
		INSERT dbo.AspNetUserRoles(UserId, RoleId)
		SELECT u.UserID, r.Id
		FROM dbo.Users AS u
		JOIN dbo.AspNetRoles AS r ON r.NormalizedName = UPPER(u.Role)
		WHERE NOT EXISTS (
			SELECT 1 FROM dbo.AspNetUserRoles AS ur
			WHERE ur.UserId = u.UserID AND ur.RoleId = r.Id
		);');

	DECLARE @RoleDefaultConstraint sysname;
	SELECT @RoleDefaultConstraint = dc.name
	FROM sys.default_constraints AS dc
	JOIN sys.columns AS c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
	WHERE dc.parent_object_id = OBJECT_ID('dbo.Users') AND c.name = 'Role';

	IF @RoleDefaultConstraint IS NOT NULL
	BEGIN
		DECLARE @DropConstraintSql nvarchar(max) =
			N'ALTER TABLE dbo.Users DROP CONSTRAINT ' + QUOTENAME(@RoleDefaultConstraint);
		EXEC sys.sp_executesql @DropConstraintSql;
	END;

	IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID('dbo.Users') AND name = 'CK_Users_Role')
		ALTER TABLE dbo.Users DROP CONSTRAINT CK_Users_Role;
	ALTER TABLE dbo.Users DROP COLUMN Role;
END;
GO
