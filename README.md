# Weekly KPI Report (Power BI + SQL Server)

An automated weekly KPI reporting project built on the AdventureWorks data warehouse. A Power BI dashboard shows this week's performance against last week and the 4-week average. The next phases add an LLM-written plain-English summary and automatic email delivery.

![Dashboard screenshot](images/dashboard.png)

## Project status

| Phase | Status |
|---|---|
| 1. Data restored to SQL Server, reporting view built | Done |
| 2. Power BI model, DAX measures, one-page dashboard | Done |
| 3. LLM-generated weekly summary (Python) | Planned |
| 4. Scheduled refresh and automatic email (Power Automate) | Planned |

## Goal

Replace the manual weekly reporting cycle (pull data, build charts, write commentary, send an email) with a repeatable process. This repository covers the data model and dashboard. The summary and email automation come next.

## Tech stack

- **SQL Server 2025 Developer:** hosts the AdventureWorksDW2025 database
- **SQL (T-SQL):** reporting view `vw_KPI_Sales` joining the sales fact table to date, product and territory dimensions
- **Power BI Desktop:** data model, DAX measures, dashboard
- **Planned:** Python with an LLM API for the written summary, Power Automate for scheduling and email

## Data

Microsoft's AdventureWorksDW2025 sample data warehouse (`FactInternetSales` with `DimDate`, `DimProduct`, `DimProductSubcategory`, `DimProductCategory`, `DimSalesTerritory`, `DimCustomer`). The data is historical, so a window of consecutive weeks is replayed as if each week were a new weekly delivery.

The database backup is not included in this repository. Download it from Microsoft's AdventureWorks sample page and restore it with `RESTORE DATABASE`.

## KPIs

All KPIs are shown for the selected week, last week, week-over-week (WoW) change and WoW %. Weeks run Monday to Sunday.

| KPI | Definition |
|---|---|
| Revenue | Sum of `SalesAmount` |
| Orders | Distinct count of `SalesOrderNumber` |
| Average order value | Revenue divided by orders |
| Units | Sum of `OrderQuantity` |
| New customers | Customers whose first order in the data falls in the week |
| Gross profit | `SalesAmount` minus `TotalProductCost` |

Revenue also has a 4-week average comparison. Revenue is broken down by product category and country, and a top movers table shows the subcategories with the biggest week-over-week change.

## Repository structure

```
.
├── README.md
├── sql/
│   └── vw_KPI_Sales.sql        # reporting view
├── dax/
│   └── measures.md             # all DAX measures
├── powerbi/
│   └── Weekly_KPI_Report.pbix  # dashboard file
└── images/
    └── dashboard.png           # screenshot
```

## How to reproduce

1. Install SQL Server 2025 Developer and restore `AdventureWorksDW2025` from the `.bak` file.
2. Run `sql/vw_KPI_Sales.sql` to create the reporting view.
3. Open `powerbi/Weekly_KPI_Report.pbix` in Power BI Desktop and point the data source to your server (`localhost`, database `AdventureWorksDW2025`).
4. Pick a week in the slicer. With no selection, the report shows the latest week.

## Design decisions

- **Reporting view instead of raw tables:** keeps the Power BI model simple and the logic in one place.
- **Disconnected week table:** lets one slicer drive "this week vs last week" for every measure.
- **`DIVIDE` everywhere:** the first week has no comparison week, so percentages show blank rather than errors.
- **Validation:** each KPI was checked against a matching SQL query for several weeks.

## Roadmap

- Python script that sends the weekly KPI figures to an LLM and returns a short summary: what changed, the main driver, and one thing to watch
- Power Automate flow that runs weekly and emails the summary with a link to the report
- Published report with scheduled refresh

## Author

Mididoddi Sai Karthik, [LinkedIn link](https://www.linkedin.com/in/sai-karthik-230290300).
