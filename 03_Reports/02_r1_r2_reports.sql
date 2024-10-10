---------------------------------------------------

-- Provide aggregate data to Regulators (R1 and R2)

---------------------------------------------------

-- R1 Report: UK Entity


SELECT 
    SUM(t.Amount_GBP) AS Total_Volumen_GBP
FROM 
    `wiseentitydataflow.wise_dataset.transactions` t
JOIN 
    `wiseentitydataflow.wise_dataset.customers` c ON t.Customer_Id = c.Customer_Id
-- Filter by transaction date, customer address country and currency route
WHERE t.Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01'
AND c.Current_Address_Country = 'UK'
AND t.Currency_Route LIKE 'GBP%'
-- 892

-- Data validation

-- Dates
-- Let's validate if the date filter is correct

SELECT
    -- No filters
    (SELECT MIN(CAST(Transaction_Date as STRING)) FROM `wiseentitydataflow.wise_dataset.transactions`) AS min_date_no_filters,
    (SELECT MAX(CAST(Transaction_Date as STRING)) FROM `wiseentitydataflow.wise_dataset.transactions`) AS max_date_no_filters,  
    -- with filters
    MIN(CAST(Transaction_Date as STRING)) AS min_date_r1, 
    MAX(CAST(Transaction_Date as STRING)) AS max_date_r1
FROM 
  `wiseentitydataflow.wise_dataset.transactions`
WHERE CAST(Transaction_Date as STRING) BETWEEN '2022-04-01' AND '2023-08-01'
AND Customer_Id IN (SELECT Customer_Id FROM `wiseentitydataflow.wise_dataset.customers` WHERE Current_Address_Country = 'UK')
AND Currency_Route LIKE 'GBP%';

-- let's review in detail year-month
SELECT
    -- No filters: Group by year-month
    FORMAT_DATE('%Y-%m', Transaction_Date) AS year_month_no_filters,
    COUNT(*) AS total_transactions_no_filters,
    
    -- With filters: Group by year-month and apply filters
    (CASE 
        WHEN Customer_Id IN (SELECT Customer_Id FROM `wiseentitydataflow.wise_dataset.customers` WHERE Current_Address_Country = 'UK')
        AND Currency_Route LIKE 'GBP%'
        THEN FORMAT_DATE('%Y-%m', Transaction_Date) 
        ELSE NULL
    END) AS year_month_with_filters,
    COUNT(CASE 
        WHEN Customer_Id IN (SELECT Customer_Id FROM `wiseentitydataflow.wise_dataset.customers` WHERE Current_Address_Country = 'UK')
        AND Currency_Route LIKE 'GBP%'
        THEN 1
        ELSE NULL
    END) AS total_transactions_with_filters

FROM 
    `wiseentitydataflow.wise_dataset.transactions`
WHERE Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01'
AND Customer_Id IN (SELECT Customer_Id FROM `wiseentitydataflow.wise_dataset.customers` WHERE Current_Address_Country = 'UK')
GROUP BY year_month_no_filters, year_month_with_filters
ORDER BY year_month_no_filters;


-- Let's check if the amounts are correctly estimated
SELECT
    -- Total SUM(Amount_GBP) without any additional filter
    SUM(Amount_GBP) AS total_volumen_gbp,

    -- Total SUM(Amount_GBP) with filter of Current_Address_Country = 'UK'
    SUM(CASE 
        WHEN Customer_Id IN (SELECT Customer_Id FROM `wiseentitydataflow.wise_dataset.customers` WHERE Current_Address_Country = 'UK') 
        THEN Amount_GBP 
        ELSE 0 
    END) AS total_volumen_gbp_uk,

    -- Total SUM(Amount_GBP) with Currency_Route LIKE 'GBP%' filter
    SUM(CASE 
        WHEN Currency_Route LIKE 'GBP%' 
        THEN Amount_GBP 
        ELSE 0 
    END) AS total_volumen_gbp_currency_route,
    -- Total SUM(Amount_GBP) with both filters (Current_Address_Country = 'UK' and Currency_Route LIKE 'GBP%')
    SUM(CASE 
        WHEN Customer_Id IN (SELECT Customer_Id FROM `wiseentitydataflow.wise_dataset.customers` WHERE Current_Address_Country = 'UK') 
        AND Currency_Route LIKE 'GBP%' 
        THEN Amount_GBP 
        ELSE 0 
    END) AS total_volumen_gbp_both_filters
FROM 
    `wiseentitydataflow.wise_dataset.transactions`
WHERE 
    Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01';


---------------------------------------------------
---------------------------------------------------

-- R2 Report: USA Entity

--1. Total volume of GBP transactions involving foreign exchange:

SELECT 
    SUM(t.Amount_GBP) AS Total_Cross_Currency_GBP 
FROM 
    `wiseentitydataflow.wise_dataset.transactions` t
JOIN 
    `wiseentitydataflow.wise_dataset.customers` c 
ON t.Customer_Id = c.Customer_Id
WHERE t.Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01'
AND c.Current_Address_Country = 'USA'
AND t.Currency_Route LIKE 'GBP%' 
AND t.Currency_Route NOT LIKE '%GBP' -- Destination currency is not GBP


-- Data validation


-- Let's validate if the date filter is correct

SELECT 
    COUNT(*) Total_Transactions,
    -- Min and max date without date filters
    MIN(t.Transaction_Date) AS Min_Date_No_Filter,
    MAX(t.Transaction_Date) AS Max_Date_No_Filter,
    -- Min and max date with date filters
    MIN(CASE 
        WHEN t.Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01' 
        THEN t.Transaction_Date 
        ELSE NULL 
    END) AS Min_Date_With_Filter,
    MAX(CASE 
        WHEN t.Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01' 
        THEN t.Transaction_Date 
        ELSE NULL 
    END) AS Max_Date_With_Filter
FROM 
    `wiseentitydataflow.wise_dataset.transactions` t
JOIN 
    `wiseentitydataflow.wise_dataset.customers` c 
ON t.Customer_Id = c.Customer_Id
WHERE c.Current_Address_Country = 'USA'
AND t.Currency_Route LIKE 'GBP%' 
AND t.Currency_Route NOT LIKE '%GBP';



-- Let's validate if Amount_GBP, Current_Address_Country, Currency_Route are correct
SELECT 
    -- Total sum of Amount_GBP without filters
    SUM(t.Amount_GBP) AS Total_Without_Filters,

    -- Sum with filter of Current_Address_Country = 'USA'
    SUM(CASE 
        WHEN c.Current_Address_Country = 'USA' 
        THEN t.Amount_GBP 
        ELSE 0 
    END) AS Total_With_Country_Filter,

    -- Sum with Currency_Route filter LIKE 'GBP%
    SUM(CASE 
        WHEN t.Currency_Route LIKE 'GBP%' 
        THEN t.Amount_GBP 
        ELSE 0 
    END) AS Total_With_Currency_Route_Filter,

    -- Sum with Currency_Route filter NOT LIKE '%GBP'
    SUM(CASE 
        WHEN t.Currency_Route NOT LIKE '%GBP' 
        THEN t.Amount_GBP 
        ELSE 0 
    END) AS Total_With_Not_GBP_Filter,

    -- Sum with all filters applied
    SUM(CASE 
        WHEN c.Current_Address_Country = 'USA' 
            AND t.Currency_Route LIKE 'GBP%' 
            AND t.Currency_Route NOT LIKE '%GBP' 
        THEN t.Amount_GBP 
        ELSE 0 
    END) AS Total_With_All_Filters

FROM 
    `wiseentitydataflow.wise_dataset.transactions` t
JOIN 
    `wiseentitydataflow.wise_dataset.customers` c 
ON t.Customer_Id = c.Customer_Id;

----------------------------------------------------

-- 2. Total same-currency volume in GBP under US Entity between 01/04/2022 and 01/08/2023:


SELECT SUM(t.Amount_GBP) AS Total_Same_Currency_GBP 
FROM `wiseentitydataflow.wise_dataset.transactions` t
JOIN `wiseentitydataflow.wise_dataset.customers` c ON t.Customer_Id = c.Customer_Id
WHERE t.Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01'
AND c.Current_Address_Country = 'USA'
AND t.Currency_Route LIKE 'GBP%' 
AND t.Currency_Route LIKE '%GBP'; -- Destination currency is GBP
-- There are no cases between 01/04/2022 and 01/08/2023 with GBP as the same currency 


-- Data Validation: Lets see how Currency_Rout changes in 3 different scenarios

SELECT 
    -- Scenario 1: Currency_Route NOT LIKE '%GBP%'
    'Not Like GBP%' AS Scenario,
    COUNT(t.Transaction_Id) AS Transaction_Count,
    ARRAY_AGG(DISTINCT t.Currency_Route) AS Currency_Routes

FROM 
    `wiseentitydataflow.wise_dataset.transactions` t
JOIN 
    `wiseentitydataflow.wise_dataset.customers` c 
ON t.Customer_Id = c.Customer_Id
WHERE 
    t.Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01'
    AND c.Current_Address_Country = 'USA'
    AND t.Currency_Route NOT LIKE '%GBP%'

UNION ALL

SELECT 
    -- Scenario 2: Currency_Route LIKE 'GBP%'
    'Like GBP%' AS Scenario,
    COUNT(t.Transaction_Id) AS Transaction_Count,
    ARRAY_AGG(DISTINCT t.Currency_Route) AS Currency_Routes

FROM 
    `wiseentitydataflow.wise_dataset.transactions` t
JOIN 
    `wiseentitydataflow.wise_dataset.customers` c 
ON t.Customer_Id = c.Customer_Id
WHERE 
    t.Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01'
    AND c.Current_Address_Country = 'USA'
    AND t.Currency_Route LIKE 'GBP%'

UNION ALL

SELECT 
    -- Scenario 3: Currency_Route LIKE '%GBP'
    'Like %GBP' AS Scenario,
    COUNT(t.Transaction_Id) AS Transaction_Count,
    ARRAY_AGG(DISTINCT t.Currency_Route) AS Currency_Routes

FROM 
    `wiseentitydataflow.wise_dataset.transactions` t
JOIN 
    `wiseentitydataflow.wise_dataset.customers` c 
ON t.Customer_Id = c.Customer_Id
WHERE 
    t.Transaction_Date BETWEEN '2022-04-01' AND '2023-08-01'
    AND c.Current_Address_Country = 'USA'
    AND t.Currency_Route LIKE '%GBP';

