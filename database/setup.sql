
IF DB_ID(N'AutoLot') IS NULL CREATE DATABASE AutoLot;
GO
USE AutoLot;
GO
CREATE TABLE dbo.Users (
 UserID int IDENTITY PRIMARY KEY, Email nvarchar(254) NOT NULL UNIQUE,
 PasswordHash nvarchar(500) NOT NULL, FullName nvarchar(100) NOT NULL,
 Phone nvarchar(30) NULL, Role nvarchar(20) NOT NULL DEFAULT 'Customer',
 CONSTRAINT CK_Users_Role CHECK (Role IN ('Customer','Employee'))
);
CREATE TABLE dbo.Makes (MakeID int IDENTITY PRIMARY KEY, Name nvarchar(80) NOT NULL UNIQUE);
CREATE TABLE dbo.Models (ModelID int IDENTITY PRIMARY KEY, MakeID int NOT NULL REFERENCES dbo.Makes(MakeID), Name nvarchar(80) NOT NULL, UNIQUE(MakeID,Name));
CREATE TABLE dbo.Vehicles (
 VehicleID int IDENTITY PRIMARY KEY, ModelID int NOT NULL REFERENCES dbo.Models(ModelID), VIN varchar(17) NOT NULL UNIQUE,
 Year int NOT NULL CHECK (Year BETWEEN 1886 AND 2100), Mileage int NOT NULL CHECK (Mileage>=0),
 AskingPrice decimal(12,2) NOT NULL CHECK (AskingPrice>=0), SalePrice decimal(12,2) NULL,
 BodyStyle nvarchar(50) NULL, FuelType nvarchar(50) NULL, Transmission nvarchar(50) NULL,
 EngineDetails nvarchar(100) NULL, Color nvarchar(50) NULL, VehicleCondition nvarchar(50) NULL,
 Description nvarchar(max) NULL, AvailabilityStatus nvarchar(20) NOT NULL DEFAULT 'For Sale',
 IsFeatured bit NOT NULL DEFAULT 0, IsActive bit NOT NULL DEFAULT 1,
 CONSTRAINT CK_Vehicles_SalePrice CHECK (SalePrice IS NULL OR (SalePrice>=0 AND SalePrice<AskingPrice)),
 CONSTRAINT CK_Vehicles_Status CHECK (AvailabilityStatus IN ('For Sale','Reserved','Sold'))
);
CREATE TABLE dbo.VehiclePhotos (
 PhotoID int IDENTITY PRIMARY KEY, VehicleID int NOT NULL REFERENCES dbo.Vehicles(VehicleID),
 ImageLocation nvarchar(1000) NOT NULL, AltText nvarchar(250) NOT NULL, DisplayOrder int NOT NULL DEFAULT 0
);
CREATE TABLE dbo.TestDriveRequests (
 TestDriveID int IDENTITY PRIMARY KEY, UserID int NOT NULL REFERENCES dbo.Users(UserID), VehicleID int NOT NULL REFERENCES dbo.Vehicles(VehicleID),
 PreferredDateTime datetime2 NOT NULL, Status nvarchar(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending','Confirmed','Declined','Cancelled'))
);
CREATE TABLE dbo.Reservations (
 ReservationID int IDENTITY PRIMARY KEY, UserID int NOT NULL REFERENCES dbo.Users(UserID), VehicleID int NOT NULL REFERENCES dbo.Vehicles(VehicleID),
 RequestDate datetime2 NOT NULL DEFAULT SYSUTCDATETIME(), Status nvarchar(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending','Confirmed','Declined','Cancelled'))
);
CREATE UNIQUE INDEX UX_Reservations_Confirmed ON dbo.Reservations(VehicleID) WHERE Status='Confirmed';
CREATE TABLE dbo.Inquiries (
 InquiryID int IDENTITY PRIMARY KEY, VehicleID int NULL REFERENCES dbo.Vehicles(VehicleID), SenderName nvarchar(100) NOT NULL,
 Email nvarchar(254) NOT NULL, Message nvarchar(4000) NOT NULL, CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
 Status nvarchar(20) NOT NULL DEFAULT 'New' CHECK (Status IN ('New','Read','Closed'))
);
GO
-- Fictional examples for development only.
INSERT dbo.Makes(Name) VALUES ('Toyota'), ('Ford'), ('Honda');
INSERT dbo.Models(MakeID,Name) SELECT MakeID,'Camry' FROM dbo.Makes WHERE Name='Toyota';
INSERT dbo.Models(MakeID,Name) SELECT MakeID,'Mustang' FROM dbo.Makes WHERE Name='Ford';
INSERT dbo.Models(MakeID,Name) SELECT MakeID,'Civic' FROM dbo.Makes WHERE Name='Honda';
INSERT dbo.Vehicles(ModelID,VIN,Year,Mileage,AskingPrice,SalePrice,BodyStyle,FuelType,Transmission,Color,VehicleCondition,Description,IsFeatured)
SELECT ModelID,'EXAMPLE0000000001',2022,27000,24900,23500,'Sedan','Gasoline','Automatic','Silver','Used','A comfortable everyday sedan.',1 FROM dbo.Models WHERE Name='Camry';
INSERT dbo.Vehicles(ModelID,VIN,Year,Mileage,AskingPrice,BodyStyle,FuelType,Transmission,Color,VehicleCondition,Description,IsFeatured)
SELECT ModelID,'EXAMPLE0000000002',2021,32000,28900,'Coupe','Gasoline','Automatic','Blue','Used','A sporty coupe with room for weekend drives.',1 FROM dbo.Models WHERE Name='Mustang';
INSERT dbo.Vehicles(ModelID,VIN,Year,Mileage,AskingPrice,BodyStyle,FuelType,Transmission,Color,VehicleCondition,Description)
SELECT ModelID,'EXAMPLE0000000003',2020,40000,19900,'Sedan','Gasoline','Automatic','White','Used','A compact sedan for daily driving.' FROM dbo.Models WHERE Name='Civic';
GO
