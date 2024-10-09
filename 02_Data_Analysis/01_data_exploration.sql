-- 1. General Data Exploration
-- 1.1 Basic Data Statistics (Transactions Table)
-- This query provides general statistics on the transactions table, including the total number of transactions, minimum, -- maximum, and average transaction amounts, as well as a count of transactions with negative amounts.

-- Query: Basic statistics for the 'transactions' table
SELECT
    COUNT(DISTINCT Transaction_Id) AS total_transactions, -- Total number of transactions
    MIN(Transaction_Date) AS earliest_transaction_date, -- Date of the earliest transaction
    MAX(Transaction_Date) AS latest_transaction_date, -- Date of the latest transaction
    MIN(Amount_GBP) AS min_transaction_amount, -- Minimum transaction amount
    MAX(Amount_GBP) AS max_transaction_amount, -- Maximum transaction amount
    AVG(Amount_GBP) AS avg_transaction_amount, -- Average transaction amount
    COUNTIF(Amount_GBP < 0) AS negative_transaction_count -- Number of transactions with negative amounts
FROM
    `wiseentitydataflow.wise_dataset.transactions`;


-- 1.2 Basic Data Statistics (Customers Table)
-- This query provides basic information on the customers table, including the total number of customers and 
-- the count of null values in the Customer_Type field.


-- Query: Basic statistics for the 'customers' table
SELECT
    COUNT(DISTINCT Customer_Id) AS total_customers, -- Total number of customers
    COUNTIF(Customer_Type = "NULL") AS null_customer_type_count, -- Number of customers with null Customer_Type
    COUNTIF(Customer_Type = 'Business') AS total_business_customers, -- Total number of Business customers
    COUNTIF(Customer_Type = 'Personal') AS total_personal_customers -- Total number of Personal customers
FROM
    `wiseentitydataflow.wise_dataset.customers`;


-- 2. Data Cleaning Insights
-- 2.1 Investigating Negative Transactions
-- We need to investigate why there are negative amounts in the transactions table, as this could indicate errors or refunds. 
-- The following query retrieves the details of all transactions with negative amounts.


-- Query: Retrieve transactions with negative amounts
SELECT
    Transaction_Id,
    Customer_Id,
    Amount_GBP,
    Currency_Route,
    Transaction_Date
FROM
    `wiseentitydataflow.wise_dataset.transactions`
WHERE
    Amount_GBP < 0;


-- 2.2 Investigating Null Values in Customer_Type
-- We need to investigate customers whose Customer_Type is null to understand if there is a pattern that could help classify them. This query retrieves detailed customer information for those records.


-- Query: Retrieve customers with null Customer_Type
SELECT
    Customer_Id,
    Current_Address_Country,
    Customer_Since_Date
FROM
    `wiseentitydataflow.wise_dataset.customers`
WHERE
    Customer_Type = "NULL";


3. Data Segmentation Using Quintiles
Quintile tables help segment data into five equal parts based on transaction amounts. This is useful for understanding the distribution of values, identifying outliers, and spotting trends.

3.1 Quintile Distribution of Transaction Amounts
This query calculates the quintiles for the transaction amounts (Amount_GBP) in the transactions table, allowing us to see the distribution across different ranges.


-- Query: Quintile distribution of transaction amounts
WITH quintile_data AS (
    SELECT
        Amount_GBP,
        NTILE(5) OVER (ORDER BY Amount_GBP) AS quintile -- NTILE function creates 5 segments (quintiles)
    FROM
        `wiseentitydataflow.wise_dataset.transactions`
    WHERE
        Amount_GBP >= 0 -- Exclude negative amounts for this analysis
)
SELECT
    quintile, -- Quintile number
    COUNT(*) AS transaction_count, -- Count of transactions in this quintile
    MIN(Amount_GBP) AS min_amount, -- Minimum amount in this quintile
    MAX(Amount_GBP) AS max_amount, -- Maximum amount in this quintile
    AVG(Amount_GBP) AS avg_amount -- Average amount in this quintile
FROM
    quintile_data
GROUP BY
    quintile
ORDER BY
    quintile;

3.2 Quintile Distribution by Customer Type
This query segments the transactions into quintiles, grouped by Customer_Type, to analyze how transaction amounts differ between Business, Personal, and Unknown customers.

sql
Copy code
-- Query: Quintile distribution by Customer_Type
WITH quintile_data AS (
    SELECT
        t.Amount_GBP,
        c.Customer_Type,
        NTILE(5) OVER (ORDER BY t.Amount_GBP) AS quintile -- NTILE function creates 5 segments (quintiles)
    FROM
        `wiseentitydataflow.wise_dataset.transactions` t
    INNER JOIN
        `wiseentitydataflow.wise_dataset.customers` c
    ON
        t.Customer_Id = c.Customer_Id
    WHERE
        t.Amount_GBP >= 0 -- Exclude negative amounts for this analysis
)
SELECT
    quintile,
    Customer_Type,
    COUNT(*) AS transaction_count,
    MIN(Amount_GBP) AS min_amount,
    MAX(Amount_GBP) AS max_amount,
    AVG(Amount_GBP) AS avg_amount
FROM
    quintile_data
GROUP BY
    quintile, Customer_Type
ORDER BY
    quintile, Customer_Type;
4. Historical Data Analysis
4.1 Transaction Volume Over Time
This query aggregates the number of transactions and their total volume over time. We can break this down by month or week to analyze transaction patterns.

sql
Copy code
-- Query: Transaction volume over time (monthly)
SELECT
    EXTRACT(YEAR FROM t.Transaction_Date) AS year,
    EXTRACT(MONTH FROM t.Transaction_Date) AS month,
    COUNT(t.Transaction_Id) AS total_transactions, -- Total number of transactions
    SUM(t.Amount_GBP) AS total_volume_gbp -- Total volume of transactions in GBP
FROM
    `wiseentitydataflow.wise_dataset.transactions` t
GROUP BY
    year, month
ORDER BY
    year, month;
4.2 Transaction Trends by Customer Type
This query explores how the transaction volume has changed over time, broken down by Customer_Type. This will help identify any trends between Business, Personal, and Unknown customers.

sql
Copy code
-- Query: Transaction volume over time by Customer_Type (monthly)
SELECT
    EXTRACT(YEAR FROM t.Transaction_Date) AS year,
    EXTRACT(MONTH FROM t.Transaction_Date) AS month,
    c.Customer_Type,
    COUNT(t.Transaction_Id) AS total_transactions,
    SUM(t.Amount_GBP) AS total_volume_gbp
FROM
    `wiseentitydataflow.wise_dataset.transactions` t
INNER JOIN
    `wiseentitydataflow.wise_dataset.customers` c
ON
    t.Customer_Id = c.Customer_Id
GROUP BY
    year, month, c.Customer_Type
ORDER BY
    year, month, c.Customer_Type;
5. Anomaly Detection and Outlier Analysis
5.1 Identifying Outliers in Transaction Amounts
This query helps to identify outliers by focusing on transactions that fall beyond the 1st and 99th percentiles, which could indicate abnormal behavior or errors.

sql
Copy code
-- Query: Identify outliers in transaction amounts
WITH percentiles AS (
    SELECT
        PERCENTILE_CONT(Amount_GBP, 0.01) OVER () AS p01, -- 1st percentile
        PERCENTILE_CONT(Amount_GBP, 0.99) OVER () AS p99  -- 99th percentile
    FROM
        `wiseentitydataflow.wise_dataset.transactions`
)
SELECT
    t.Transaction_Id,
    t.Customer_Id,
    t.Amount_GBP,
    t.Currency_Route,
    t.Transaction_Date
FROM
    `wiseentitydataflow.wise_dataset.transactions` t,
    percentiles p
WHERE
    t.Amount_GBP < p.p01 OR t.Amount_GBP > p.p99; -- Outliers defined as outside the 1st and 99th percentiles
