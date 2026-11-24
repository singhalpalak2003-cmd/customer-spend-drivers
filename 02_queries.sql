-- =====================================================================
-- Customer Spend Drivers - SQL query set (SQLite)
-- Student: Palak Singhal | Roll No: 26-PGDM083   File: sql/02_queries.sql
-- Key business question: Which customer characteristics are linked to
-- higher total spend, and where should marketing money go?
-- Reference year for age = 2014 (last sign-up in the data is June 2014).
-- =====================================================================

-- Q1 | SELECT, ORDER BY, LIMIT
-- Business question: Who are our 10 highest-spending customers?
SELECT c.customer_id, c.education, c.income,
       (s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold) AS total_spend
FROM customers c
JOIN spend s ON s.customer_id = c.customer_id
ORDER BY total_spend DESC
LIMIT 10;

-- Q2 | WHERE with AND, OR, IN, BETWEEN, LIKE
-- Business question: How many mid-income, postgraduate customers with a partner could form a premium wine campaign list?
SELECT COUNT(*) AS target_customers
FROM customers c
JOIN spend s ON s.customer_id = c.customer_id
WHERE c.education IN ('Master', 'PhD', '2n Cycle')
  AND c.income BETWEEN 50000 AND 90000
  AND (c.marital_status LIKE 'Marr%' OR c.marital_status = 'Together')
  AND s.mnt_wines > 300;

-- Q3 | NULL handling: IS NULL, COALESCE
-- Business question: Do customers with a missing income behave differently, and what happens if we fill the gap with the average income?
SELECT CASE WHEN c.income IS NULL THEN 'Income missing' ELSE 'Income recorded' END AS income_status,
       COUNT(*)                                                                    AS customers,
       ROUND(AVG(c.income), 0)                                                     AS avg_income_raw,
       ROUND(AVG(COALESCE(c.income, (SELECT AVG(income) FROM customers))), 0)     AS avg_income_filled,
       ROUND(AVG(s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold), 1) AS avg_spend
FROM customers c
JOIN spend s ON s.customer_id = c.customer_id
GROUP BY income_status;

-- Q4 | Functions: CASE WHEN, ROUND, strftime (date function)
-- Business question: How does spend differ across income bands and sign-up years?
SELECT CASE WHEN c.income IS NULL     THEN 'Unknown'
            WHEN c.income < 35000     THEN '1 Low (<35K)'
            WHEN c.income < 70000     THEN '2 Mid (35-70K)'
            ELSE                           '3 High (70K+)' END   AS income_band,
       strftime('%Y', c.dt_customer)                            AS signup_year,
       COUNT(*)                                                 AS customers,
       ROUND(AVG(s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold), 1) AS avg_spend
FROM customers c
JOIN spend s ON s.customer_id = c.customer_id
GROUP BY income_band, signup_year
ORDER BY income_band, signup_year;

-- Q5 | Aggregations: COUNT, SUM, AVG, MIN, MAX
-- Business question: What is the overall size and spread of customer spend?
SELECT COUNT(*)                                                        AS customers,
       ROUND(SUM(mnt_wines + mnt_fruits + mnt_meat + mnt_fish + mnt_sweets + mnt_gold), 0) AS total_revenue,
       ROUND(AVG(mnt_wines + mnt_fruits + mnt_meat + mnt_fish + mnt_sweets + mnt_gold), 1) AS avg_spend,
       MIN(mnt_wines + mnt_fruits + mnt_meat + mnt_fish + mnt_sweets + mnt_gold)           AS min_spend,
       MAX(mnt_wines + mnt_fruits + mnt_meat + mnt_fish + mnt_sweets + mnt_gold)           AS max_spend
FROM spend;

-- Q6 | GROUP BY + HAVING
-- Business question: Which education groups (with at least 100 customers) spend the most on average?
SELECT c.education,
       COUNT(*)                                                                             AS customers,
       ROUND(AVG(s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold), 1) AS avg_spend,
       ROUND(AVG(c.income), 0)                                                              AS avg_income
FROM customers c
JOIN spend s ON s.customer_id = c.customer_id
GROUP BY c.education
HAVING COUNT(*) >= 100
ORDER BY avg_spend DESC;

-- Q7 | INNER JOIN (key business question: household size and spend)
-- Business question: How much less do households with children spend?
SELECT (c.kidhome + c.teenhome)                                                             AS children_at_home,
       COUNT(*)                                                                             AS customers,
       ROUND(AVG(s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold), 1) AS avg_spend,
       ROUND(AVG(c.income), 0)                                                              AS avg_income
FROM customers c
INNER JOIN spend s ON s.customer_id = c.customer_id
GROUP BY children_at_home
ORDER BY children_at_home;

-- Q8 | LEFT JOIN
-- Business question: Do customers who never accept any campaign spend less than those who accept at least one?
SELECT CASE WHEN a.customer_id IS NULL THEN 'Never accepted' ELSE 'Accepted 1+' END AS group_label,
       COUNT(DISTINCT c.customer_id)                                                   AS customers,
       ROUND(AVG(s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold), 1) AS avg_spend
FROM customers c
JOIN spend s ON s.customer_id = c.customer_id
LEFT JOIN campaign_accepts a ON a.customer_id = c.customer_id
GROUP BY group_label
ORDER BY avg_spend DESC;

-- Q9 | Business link: spend by income band and household type
-- Business question: Is the income effect on spend weaker for households with children (the interaction used in the regression)?
SELECT CASE WHEN c.income < 35000 THEN '1 Low (<35K)'
            WHEN c.income < 70000 THEN '2 Mid (35-70K)'
            ELSE '3 High (70K+)' END                                                    AS income_band,
       CASE WHEN c.kidhome + c.teenhome > 0 THEN 'With children' ELSE 'No children' END AS household,
       COUNT(*)                                                                         AS customers,
       ROUND(AVG(s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold), 1) AS avg_spend
FROM customers c
JOIN spend s ON s.customer_id = c.customer_id
WHERE c.income IS NOT NULL AND c.income < 600000
GROUP BY income_band, household
ORDER BY income_band, household;

-- Q10 | Business link: category mix by income band
-- Business question: What share of each income band's budget goes to wine versus everyday categories?
SELECT CASE WHEN c.income < 35000 THEN '1 Low (<35K)'
            WHEN c.income < 70000 THEN '2 Mid (35-70K)'
            ELSE '3 High (70K+)' END                                                      AS income_band,
       ROUND(100.0 * SUM(s.mnt_wines) / SUM(s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold), 1) AS wine_pct,
       ROUND(100.0 * SUM(s.mnt_meat)  / SUM(s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold), 1) AS meat_pct,
       ROUND(100.0 * SUM(s.mnt_fruits + s.mnt_fish + s.mnt_sweets + s.mnt_gold) / SUM(s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold), 1) AS other_pct
FROM customers c
JOIN spend s ON s.customer_id = c.customer_id
WHERE c.income IS NOT NULL AND c.income < 600000
GROUP BY income_band
ORDER BY income_band;

-- Q11 | Subquery: customers above the average spend
-- Business question: What share of customers spend more than the average, and which channel do they use most?
SELECT COUNT(*)                         AS above_avg_customers,
       ROUND(AVG(s.num_web), 2)         AS avg_web,
       ROUND(AVG(s.num_catalog), 2)     AS avg_catalog,
       ROUND(AVG(s.num_store), 2)       AS avg_store,
       ROUND(AVG(s.web_visits_month), 2) AS avg_web_visits
FROM spend s
WHERE (s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold) >
      (SELECT AVG(mnt_wines + mnt_fruits + mnt_meat + mnt_fish + mnt_sweets + mnt_gold) FROM spend);

-- Q12 | Window function: top 3 spenders inside each education group
-- Business question: Who are the best customers in each education group for a loyalty programme?
SELECT education, customer_id, total_spend, rank_in_group
FROM (
    SELECT c.education, c.customer_id,
           (s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold) AS total_spend,
           ROW_NUMBER() OVER (PARTITION BY c.education
                              ORDER BY (s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold) DESC) AS rank_in_group
    FROM customers c
    JOIN spend s ON s.customer_id = c.customer_id
)
WHERE rank_in_group <= 3
ORDER BY education, rank_in_group;

-- Q13 | Python link: customer-level extract used for charts / regression
-- Exported to outputs/sql_customer_extract.csv and loaded with pd.read_sql in the notebook
SELECT c.customer_id,
       2014 - c.year_birth                                         AS age,
       c.education, c.marital_status, c.income,
       c.kidhome + c.teenhome                                      AS children,
       c.recency,
       s.num_deals, s.web_visits_month,
       (s.mnt_wines + s.mnt_fruits + s.mnt_meat + s.mnt_fish + s.mnt_sweets + s.mnt_gold) AS total_spend,
       COUNT(a.campaign_no)                                        AS campaigns_accepted
FROM customers c
JOIN spend s ON s.customer_id = c.customer_id
LEFT JOIN campaign_accepts a ON a.customer_id = c.customer_id
GROUP BY c.customer_id;
