--*************************************************************************--
-- Title: Assignment07
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 08/17/2022, KLatimer, Created File
--08/17/2022, KLatimer, Modified File
--08/19/2022, KLatimer, Modified File
--08/20/2022, KLatimer, Modified File
--08/22/2022, KLatimer, Modified File
--08/22/2022, KLatimer, Completed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_KLatimer')
	 Begin 
	  Alter Database [Assignment07DB_KLatimer] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_KLatimer;
	 End
	Create Database Assignment07DB_KLatimer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_KLatimer;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --
--review table

--SELECT * FROM vProducts AS vPro;
--go
--select exact columns

--SELECT
	--ProductName,
	--UnitPrice
		--FROM vProducts AS vPro;
--go
--Order by
--SELECT
	--ProductName,
	--UnitPrice
		--FROM vProducts
			--ORDER BY ProductName AS vPro;
--go

--using function format price in US dollars

--SELECT
	--ProductName,
	--Format(UnitPrice, '$', 'en-US' ) as 'US Format'
		--FROM vProducts
			--ORDER BY ProductName AS vPro;
--gO

--That didn't work :D
--second attempt

go
SELECT
	ProductName,
	Format([UnitPrice], 'C', 'en-US') AS 'UnitPrice'
		FROM vProducts
			ORDER BY ProductName;


go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --

--reviewing tables

--SELECT * FROM vCategories AS vCat;
--SELECT * FROM vProducts AS vPro;

go

--Copying part of my code from above, but adding in category data
SELECT
	vPro.ProductName,
	vCat.CategoryName,
	Format([UnitPrice], 'C', 'en-US') AS 'UnitPrice'
		FROM
			vCategories as vCat
			JOIN
			vProducts as vPro
				on 
					vCat.CategoryID = vPro.CategoryID
		ORDER BY
			vCat.CategoryName, vPro.ProductName;

go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

--Reviewing tables
--SELECT * FROM vProducts AS vPro;
--SELECT * FROM vInventories AS vInv;


--Review select data
--SELECT
	--vPro.ProductName,
	--vInv.InventoryDate,
	--vInv.[Count]
	--FROM 
	--vProducts AS vPro JOIN vInventories AS vInv
	--ON
	--vPro.ProductID = vInv.ProductID
	--ORDER BY vPro.ProductName, vInv.InventoryDate
-- go

--Converting Date to January 2017 format
--SELECT
	--vPro.ProductName,
	--FORMAT([vInv].[InventoryDate], 'MMMM, YYYY') AS 'InventoryDate',
--	vInv.[Count]
	--FROM 
	--vProducts AS vPro JOIN vInventories AS vInv
	--ON
	--vPro.ProductID = vInv.ProductID
	--ORDER BY vPro.ProductName, vInv.InventoryDate
--go
---having the capitlized Y's did not work correctly
SELECT
	vPro.ProductName,
	FORMAT([vInv].[InventoryDate], 'MMMM, yyyy') AS 'InventoryDate',
	vInv.[Count]
	FROM 
	vProducts AS vPro JOIN vInventories AS vInv
	ON
	vPro.ProductID = vInv.ProductID
	ORDER BY vPro.ProductName, vInv.InventoryDate;
go
--SUCCESS!!! :D

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
--Reviewing Tables
--SELECT * FROM vProducts;
--SELECT * FROM vInventories;

--Joining product and inventory Views by copying part of my code from question 3
--go


CREATE or ALTER VIEW
vProductInventories
AS
SELECT TOP 100000
	vPro.ProductName,
	FORMAT([vInv].[InventoryDate], 'MMMM, yyyy') AS 'InventoryDate',
	vInv.[Count]
	FROM 
	vProducts AS vPro JOIN vInventories AS vInv
	ON
	vPro.ProductID = vInv.ProductID
	ORDER BY vPro.ProductName, vInv.InventoryDate;

go

-- Check that it works: Select * From vProductInventories;

Select * From vProductInventories
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
--review table data
--SELECT * FROM vCategories as vCat;
--SELECT * FROM vInventories as vInv;


--joining select data

--SELECT
	--vCat.CategoryName,
	--FORMAT([vInv].[InventoryDate], 'MMMM, yyyy') AS 'InventoryDate',
	----SUM(vInv.[Count]) AS 'InventoryCountByCategory'
	--FROM vCategories AS vCat JOIN vProducts AS vPro
	--ON vCat.CategoryID = vPro.CategoryID
	--JOIN vInventories AS vInv 
	--ON vInv.ProductID = vPro.ProductID
		--GROUP BY vCat.CategoryName, vInv.InventoryDate
		--	--ORDER BY vCat.CategoryName, vInv.InventoryDate;
GO

--Creating View

CREATE or ALTER VIEW
vCategoryInventories
AS
SELECT TOP 100000
	vCat.CategoryName,
	FORMAT([vInv].[InventoryDate], 'MMMM, yyyy') AS 'InventoryDate',
	SUM(vInv.[Count]) AS 'InventoryCountByCategory'
	FROM vCategories AS vCat JOIN vProducts AS vPro
	ON vCat.CategoryID = vPro.CategoryID
	JOIN vInventories AS vInv 
	ON vInv.ProductID = vPro.ProductID
		GROUP BY vCat.CategoryName, vInv.InventoryDate
			ORDER BY vCat.CategoryName, vInv.InventoryDate;
GO


-- Check that it works: Select * From vCategoryInventories;

 Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
--REVIEW VIEW vProductInventories
--SELECT * FROM vProductInventories AS vProInv

--SELECT * FROM vInventories

--TESTING SELECT DATA FROM VIEW vProductInventories
--SELECT
	--vProInv.ProductName,
	--vProInv.InventoryDate,
	--vProInv.[Count]
		--FROM vProductInventories AS vProInv;

--GO
--creating view/Incomplete
--go
--CREATE OR ALTER VIEW
--vProductInventoriesWithPreviouMonthCounts
--AS
--SELECT
	--vProInv.ProductName,
	--vProInv.InventoryDate,
	--vProInv.[Count] as InventoryCount.
	--PreviousMonthCount = IIF((Month(InventoryDate) = 1, 0, IsNull(Lag(Sum([i].[Count]))


go
Create Or Alter View 
vProductInventoriesWithPreviousMonthCounts
As
Select TOP 100000
	ProductName, 
	Format([vInv].[InventoryDate], 'MMMM, yyyy') As InventoryDate, 
	[vInv].[Count],
	PreviousMonthCount = IIF(Month(InventoryDate) = 1, 0, IsNull(Lag(Sum([vInv].[Count])) 
		Over(Order By [vPro].[ProductName], Month([vInv].[InventoryDate]), Year([vInv].[InventoryDate])), 0))
			From 
			vProducts as vPRO Join  vInventories as vInv
			On vPro.ProductID = vInv.ProductID
				Group By 
				vPro.ProductName, 
				vInv.InventoryDate, 
				vInv.[Count]
					ORDER BY ProductName, Month([InventoryDate]), Year([InventoryDate]);
go


-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

--View from question 6: Select * From vProductInventoriesWithPreviousMonthCounts
GO
CREATE OR ALTER VIEW
vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
SELECT TOP 100000
	ProductName, 
	InventoryDate,
	[Count],
	PreviousMonthCount,
	CountsVsPreviousCountKPI = CASE
			When [Count] > [PreviousMonthCount] then 1
			When [Count] < [PreviousMonthCount] then -1
			When [Count] = [PreviousMonthCount] then 0
			END
	FROM
	vProductInventoriesWithPreviousMonthCounts as vPICounts
		ORDER BY ProductName, Month([InventoryDate]), Year([InventoryDate]);
GO


-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: 

Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;


go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
--CREATING FUNCTION AND COPYING CODE FROM QUESTION 7

CREATE or ALTER 
	FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs (@CountsVsPreviousCountKPI AS int)
	RETURNS TABLE
	AS	
		RETURN(
				SELECT top 100000
					ProductName, 
					InventoryDate,
					[Count],
					PreviousMonthCount,
					CountsVsPreviousCountKPI
						FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
							WHERE CountsVsPreviousCountKPI = @CountsVsPreviousCountKPI
							ORDER BY ProductName, Month([InventoryDate]), Year([InventoryDate]));
GO


Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1)


/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/