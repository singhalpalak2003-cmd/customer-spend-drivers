# Customer Spend Drivers in Retail: Python Regression and SQL Analysis

**Student:** Palak Singhal | **Roll No:** 26-PGDM083
**Course:** Data Analytics for Managers using Python: Individual Assignment (Python, SQL & Portfolio)

## Case, problem and question
- **Industry / case:** Retail (grocery and wine). 2,240 customers, 2012-2014.
- **Business problem:** The retailer spreads marketing spend evenly although customers differ greatly in how much they spend.
- **Key business question:** Which customer characteristics are linked with higher total spend over two years, and does the effect of income depend on household children and on web browsing?
- **Outcome variable:** `Total_Spend` (wine + fruit + meat + fish + sweets + gold, two years).
- **Dataset:** Customer Personality Analysis, Kaggle (`marketing_campaign.csv`). Link: [add link]. Licence: [add licence from the dataset page].

## Method
1. Cleaning: removed 182 duplicate rows, 4 impossible values (3 ages above 110, one income of 666,666) and 24 rows with missing income; merged messy category labels. Final sample 2,030.
2. Descriptive statistics, EDA (IQR outliers), 14 charts + 3 model charts.
3. Model 1: multiple linear regression without interaction (7 numeric + 2 categorical predictors).
4. Model 2: adds Income x Children and Income x Web visits.
5. Comparison: R-squared, adjusted R-squared, AIC, BIC, F-test, RMSE/MAE, 20% hold-out RMSE, nested F-test, robust (HC3) check.
6. SQL (SQLite): 3 related tables, 13 queries (filters, NULLs, functions, aggregation, GROUP BY/HAVING, INNER and LEFT JOIN, subquery, window function, export to Python).

## Main results
| Measure | Model 1 | Model 2 |
|---|---|---|
| R-squared | 0.718 | 0.738 |
| Adjusted R-squared | 0.716 | 0.736 |
| AIC | 29,211 | 29,062 |
| BIC | 29,290 | 29,152 |
| RMSE (20% hold-out) | 323 | 313 |

- Income (about +20 spend per 1,000) and children at home (about -250 per child) are the dominant drivers.
- The income effect is weaker for households with children and stronger for frequent website visitors.
- Education and marital status add nothing once income and children are controlled.
- Preferred model: Model 2.

## Repository structure
```
README.md
data/        marketing_campaign.csv, data_dictionary.md
notebooks/   Customer_Spend_Drivers_Analysis.ipynb
sql/         01_schema.sql, 02_queries.sql
outputs/     charts, model tables, query results
.gitignore
```

## Links
- Kaggle notebook: [add link]
- Word report: Palak_Singhal_26-PGDM083_Report.docx


