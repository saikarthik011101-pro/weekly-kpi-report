# DAX Measures

All measures live in a table named `_Measures`. The model has a sales view (`vw_KPI_Sales`), a marked date table (`DimDate`), and a disconnected `Weeks` table used as the week selector. Weeks run Monday to Sunday. With no week selected, the report shows the latest week.

## Week selector table

Created with Modeling > New table. It has no relationship to any other table.

```DAX
Weeks =
DISTINCT ( SELECTCOLUMNS ( vw_KPI_Sales, "WeekStart", vw_KPI_Sales[WeekStart] ) )
```

## Base measures

```DAX
Revenue = SUM ( vw_KPI_Sales[SalesAmount] )

Orders = DISTINCTCOUNT ( vw_KPI_Sales[SalesOrderNumber] )

Units = SUM ( vw_KPI_Sales[OrderQuantity] )

Gross Profit = SUM ( vw_KPI_Sales[GrossProfit] )

AOV = DIVIDE ( [Revenue], [Orders] )

New Customers =
CALCULATE (
    DISTINCTCOUNT ( vw_KPI_Sales[CustomerKey] ),
    vw_KPI_Sales[IsNewCustomerOrder] = 1
)
```

## Week selection

```DAX
Selected Week = MAX ( Weeks[WeekStart] )

Selected Week Label = "Week of " & FORMAT ( [Selected Week], "dd mmm yyyy" )
```

## This week and last week

```DAX
Revenue This Week =
VAR w = [Selected Week]
RETURN CALCULATE ( [Revenue], vw_KPI_Sales[WeekStart] = w )

Revenue Last Week =
VAR w = [Selected Week] - 7
RETURN CALCULATE ( [Revenue], vw_KPI_Sales[WeekStart] = w )

Orders This Week =
VAR w = [Selected Week]
RETURN CALCULATE ( [Orders], vw_KPI_Sales[WeekStart] = w )

Orders Last Week =
VAR w = [Selected Week] - 7
RETURN CALCULATE ( [Orders], vw_KPI_Sales[WeekStart] = w )

Units This Week =
VAR w = [Selected Week]
RETURN CALCULATE ( [Units], vw_KPI_Sales[WeekStart] = w )

Units Last Week =
VAR w = [Selected Week] - 7
RETURN CALCULATE ( [Units], vw_KPI_Sales[WeekStart] = w )

New Customers This Week =
VAR w = [Selected Week]
RETURN CALCULATE ( [New Customers], vw_KPI_Sales[WeekStart] = w )

New Customers Last Week =
VAR w = [Selected Week] - 7
RETURN CALCULATE ( [New Customers], vw_KPI_Sales[WeekStart] = w )

AOV This Week = DIVIDE ( [Revenue This Week], [Orders This Week] )

AOV Last Week = DIVIDE ( [Revenue Last Week], [Orders Last Week] )

Gross Profit This Week =
VAR w = [Selected Week]
RETURN CALCULATE ( [Gross Profit], vw_KPI_Sales[WeekStart] = w )

Gross Profit Last Week =
VAR w = [Selected Week] - 7
RETURN CALCULATE ( [Gross Profit], vw_KPI_Sales[WeekStart] = w )
```

## Week-over-week change and percentage

`DIVIDE` returns blank when last week is zero or missing, so the first week of the window shows blank instead of an error.

```DAX
Revenue WoW = [Revenue This Week] - [Revenue Last Week]
Revenue WoW % = DIVIDE ( [Revenue WoW], [Revenue Last Week] )

Orders WoW = [Orders This Week] - [Orders Last Week]
Orders WoW % = DIVIDE ( [Orders WoW], [Orders Last Week] )

Units WoW = [Units This Week] - [Units Last Week]
Units WoW % = DIVIDE ( [Units WoW], [Units Last Week] )

New Customers WoW = [New Customers This Week] - [New Customers Last Week]
New Customers WoW % = DIVIDE ( [New Customers WoW], [New Customers Last Week] )

AOV WoW = [AOV This Week] - [AOV Last Week]
AOV WoW % = DIVIDE ( [AOV WoW], [AOV Last Week] )

Gross Profit WoW % =
DIVIDE ( [Gross Profit This Week] - [Gross Profit Last Week], [Gross Profit Last Week] )
```

## Trend context: 4-week average

```DAX
Revenue 4W Avg =
VAR w = [Selected Week]
RETURN
    AVERAGEX (
        FILTER ( ALL ( Weeks[WeekStart] ), Weeks[WeekStart] > w - 28 && Weeks[WeekStart] <= w ),
        CALCULATE ( [Revenue], vw_KPI_Sales[WeekStart] = Weeks[WeekStart] )
    )

Revenue vs 4W Avg % = DIVIDE ( [Revenue This Week] - [Revenue 4W Avg], [Revenue 4W Avg] )
```

## Card labels and colours

The colour measure is applied through Format > Conditional formatting > Field value.

```DAX
Revenue Trend Label =
VAR p = [Revenue WoW %]
RETURN
    IF ( ISBLANK ( p ), "–", IF ( p > 0, "▲ ", IF ( p < 0, "▼ ", "● " ) ) & FORMAT ( ABS ( p ), "0.0%" ) )

Revenue Trend Color =
VAR p = [Revenue WoW %]
RETURN IF ( ISBLANK ( p ), "#808080", IF ( p >= 0, "#2E8B57", "#C0392B" ) )
```

## Number formats

- Revenue, Gross Profit, AOV and their This Week and Last Week versions: Currency, 0 decimals
- Everything ending in `WoW %` or `vs 4W Avg %`: Percentage, 1 decimal
- Orders, Units, New Customers: Whole number with thousands separator

## Validation

Each KPI was checked against a SQL query on `dbo.vw_KPI_Sales` grouped by `WeekStart`, for several different weeks, including the first week of the window.
