-- =====================================================================
-- Customer Spend Drivers - Retail Marketing Campaign Case
-- Student: Palak Singhal | Roll No: 26-PGDM083
-- Database: SQLite   |   File: sql/01_schema.sql
-- =====================================================================
-- Three related tables, built from marketing_campaign.csv (raw, uncleaned,
-- so that NULL handling in the queries is meaningful).
--   customers        1 row per customer (profile)
--   spend            1 row per customer (what and how they bought)
--   campaign_accepts 1 row per customer-campaign ACCEPTANCE only
--                    (customers who never accepted have no row -> LEFT JOIN)

DROP TABLE IF EXISTS campaign_accepts;
DROP TABLE IF EXISTS spend;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id    INTEGER PRIMARY KEY,
    year_birth     INTEGER NOT NULL,
    education      TEXT    NOT NULL,
    marital_status TEXT    NOT NULL,
    income         REAL,                      -- 24 NULLs in the raw data
    kidhome        INTEGER DEFAULT 0 CHECK (kidhome  >= 0),
    teenhome       INTEGER DEFAULT 0 CHECK (teenhome >= 0),
    dt_customer    TEXT    NOT NULL,          -- ISO date YYYY-MM-DD
    recency        INTEGER,                   -- days since last purchase
    complain       INTEGER DEFAULT 0
);

CREATE TABLE spend (
    customer_id        INTEGER PRIMARY KEY,
    mnt_wines          REAL, mnt_fruits  REAL, mnt_meat   REAL,
    mnt_fish           REAL, mnt_sweets  REAL, mnt_gold   REAL,
    num_deals          INTEGER,
    num_web            INTEGER,
    num_catalog        INTEGER,
    num_store          INTEGER,
    web_visits_month   INTEGER,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE campaign_accepts (
    customer_id  INTEGER NOT NULL,
    campaign_no  INTEGER NOT NULL CHECK (campaign_no BETWEEN 1 AND 6),  -- 6 = last campaign (Response)
    PRIMARY KEY (customer_id, campaign_no),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
