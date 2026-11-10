USE [master];
GO

RESTORE DATABASE [AdventureWorksDW2025]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\AdventureWorksDW2025.bak'
WITH
    MOVE N'AdventureWorksDW'     TO N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2025.mdf',
    MOVE N'AdventureWorksDW_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2025_log.ldf',
    FILE = 1,
    NOUNLOAD,
    STATS = 5;
GO

USE AdventureWorksDW2025;
SELECT COUNT(*) AS order_lines,
       MIN(OrderDate) AS first_order,
       MAX(OrderDate) AS last_order,
       SUM(SalesAmount) AS total_sales
FROM dbo.FactInternetSales;


SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


SELECT d.CalendarYear,
       d.WeekNumberOfYear,
       COUNT(DISTINCT f.SalesOrderNumber) AS orders,
       SUM(f.SalesAmount) AS revenue
FROM dbo.FactInternetSales f
JOIN dbo.DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear, d.WeekNumberOfYear
ORDER BY d.CalendarYear, d.WeekNumberOfYear;


USE AdventureWorksDW2025;
GO

CREATE OR ALTER VIEW dbo.vw_KPI_Sales AS
SELECT
    f.SalesOrderNumber,
    f.SalesOrderLineNumber,
    d.FullDateAlternateKey                                   AS OrderDate,
    DATETRUNC(ISO_WEEK, d.FullDateAlternateKey)              AS WeekStart,
    f.CustomerKey,
    f.ProductKey,
    f.SalesTerritoryKey,
    p.EnglishProductName                                     AS Product,
    sc.EnglishProductSubcategoryName                         AS Subcategory,
    c.EnglishProductCategoryName                             AS Category,
    t.SalesTerritoryRegion                                   AS Region,
    t.SalesTerritoryCountry                                  AS Country,
    f.OrderQuantity,
    f.SalesAmount,
    f.TotalProductCost,
    f.SalesAmount - f.TotalProductCost                       AS GrossProfit,
    CASE WHEN d.FullDateAlternateKey =
         MIN(d.FullDateAlternateKey) OVER (PARTITION BY f.CustomerKey)
         THEN 1 ELSE 0 END                                   AS IsNewCustomerOrder
FROM dbo.FactInternetSales f
JOIN dbo.DimDate d                 ON f.OrderDateKey = d.DateKey
JOIN dbo.DimProduct p              ON f.ProductKey = p.ProductKey
LEFT JOIN dbo.DimProductSubcategory sc ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory c ON sc.ProductCategoryKey = c.ProductCategoryKey
JOIN dbo.DimSalesTerritory t       ON f.SalesTerritoryKey = t.SalesTerritoryKey;
GO


SELECT TOP 20 * FROM dbo.vw_KPI_Sales ORDER BY OrderDate;

SELECT WeekStart, COUNT(DISTINCT SalesOrderNumber) AS orders, SUM(SalesAmount) AS revenue
FROM dbo.vw_KPI_Sales
GROUP BY WeekStart
ORDER BY WeekStart;