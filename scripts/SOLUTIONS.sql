
-- 1. Tariff-Based Customer Queries

-- 1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.
/*
This query identifies all records in the CUSTOMERS table associated with the 'Kobiye Destek' tariff plan. 
It executes a JOIN operation between CUSTOMERS and TARIFFS using the TARIFF_ID foreign key to match relational data. 
The result set is filtered to isolate specific subscriber profiles for operational verification.
*/
SELECT c.* 
FROM CUSTOMERS c 
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID 
WHERE t.NAME = 'Kobiye Destek';

-- 1.2 Find the newest customer who subscribed to this tariff.
/*
This query determines the most recent entry into the 'Kobiye Destek' tariff based on the registration timestamp. 
The records are sorted in descending order by SIGNUP_DATE, and Oracle's ROWNUM is used to limit the output to the single latest entry. 
This is used for monitoring the registration flow and verifying data insertion sequences within the database.
*/
SELECT * FROM (
    SELECT c.* 
    FROM CUSTOMERS c 
    JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID 
    WHERE t.NAME = 'Kobiye Destek' 
    ORDER BY c.SIGNUP_DATE DESC
) WHERE ROWNUM = 1;

-- 2. Tariff Distribution

-- 2.1 Find the distribution of tariffs among the customers.
/*
This query generates a quantitative report of customer distribution across all existing tariff categories. 
By utilizing a LEFT JOIN and GROUP BY clause, it counts subscribers per plan while ensuring that unused tariffs are also represented. 
This analysis provides an overview of the database population and the utilization of different schema objects.
*/
SELECT t.NAME, COUNT(c.CUSTOMER_ID) AS CUSTOMER_COUNT
FROM TARIFFS t
LEFT JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY t.NAME;

-- 3. Customer Signup Analysis

-- 3.1 Identify the earliest customers to sign up.
/*
This query identifies the records with the minimum timestamp values in the SIGNUP_DATE column. 
It employs a subquery with the MIN function to isolate the chronologically first entries regardless of their primary key order. 
Identifying these initial records is necessary for analyzing long-term data persistence and historical system logs.
*/
SELECT * FROM CUSTOMERS 
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS);

-- 3.2 Find the distribution of these earliest customers across different cities, including the total count for each city.
/*
This query analyzes the geographic distribution of the earliest entries identified in the previous step. 
The data is grouped by the CITY attribute to provide a count of pioneer subscribers per specific location. 
This helps in understanding the regional deployment of the system during its initial operational phase.
*/
SELECT CITY, COUNT(*) AS CUSTOMER_COUNT 
FROM CUSTOMERS 
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS) 
GROUP BY CITY;

-- 4. Missing Monthly Records

-- 4.1 Identify the IDs of these missing customers.
/*
This query is designed to detect inconsistencies between the CUSTOMERS table and the MONTHLY_STATS usage table. 
It uses a LEFT JOIN combined with an IS NULL condition to find customer IDs that lack a corresponding entry in the statistics table. 
This step is critical for identifying data loss or insertion errors that occurred during the database population process.
*/
SELECT c.CUSTOMER_ID 
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.CUSTOMER_ID IS NULL;

-- 4.2 Find the distribution of these missing customers across different cities.
/*
This query maps the distribution of missing records across different cities to identify potential regional patterns. 
By counting the anomalies per city, it helps determine if the data entry failure was centralized or specific to a regional node. 
This information is vital for troubleshooting systemic errors and ensuring complete data integrity across the schema.
*/
SELECT c.CITY, COUNT(c.CUSTOMER_ID) AS MISSING_COUNT 
FROM CUSTOMERS c 
LEFT JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID 
WHERE m.CUSTOMER_ID IS NULL 
GROUP BY c.CITY;

-- 5. Usage Analysis

-- 5.1 Find the customers who have used at least 75% of their data limit.
/*
This query identifies customers whose current data consumption exceeds 75% of their allocated tariff capacity. 
It calculates the threshold dynamically by joining the MONTHLY_STATS and TARIFFS tables through a mathematical filter. 
This provides insight into resource utilization and identifies users approaching their assigned hardware/quota limits.
*/
SELECT c.NAME, m.DATA_USAGE, t.DATA_LIMIT
FROM MONTHLY_STATS m
JOIN CUSTOMERS c ON m.CUSTOMER_ID = c.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.DATA_USAGE >= (t.DATA_LIMIT * 0.75);

-- 5.2 Identify the customers who have completely exhausted all of their package limits (data, minutes, and SMS).
/*
This query identifies customers who have consumed 100% or more of their assigned data, voice, and SMS quotas simultaneously. 
It uses the logical AND operator to ensure the result set only includes records where every single package limit is met or exceeded. 
Returning zero results is a valid outcome, indicating that no customer in the current dataset has fully exhausted all three service categories at once.
*/
SELECT c.NAME 
FROM MONTHLY_STATS m 
JOIN CUSTOMERS c ON m.CUSTOMER_ID = c.CUSTOMER_ID 
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID 
WHERE m.DATA_USAGE >= t.DATA_LIMIT 
  AND m.MINUTE_USAGE >= t.MINUTE_LIMIT 
  AND m.SMS_USAGE >= t.SMS_LIMIT;

-- 6. Payment Analysis

-- 6.1 Find the customers who have unpaid fees.
/*
This query retrieves the names of customers and their corresponding monthly fees for records where the payment status is marked as unpaid. 
It executes a multi-table JOIN between MONTHLY_STATS, CUSTOMERS, and TARIFFS to reconcile payment status with personal identities and fee amounts. 
Returning an empty result set is a valid outcome if all customers in the current dataset have a status other than 'Unpaid', indicating full financial compliance.
*/
SELECT c.NAME, t.MONTHLY_FEE  
FROM MONTHLY_STATS m
JOIN CUSTOMERS c ON m.CUSTOMER_ID = c.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID 
WHERE UPPER(m.PAYMENT_STATUS) = 'UNPAID';
-- 6.2 Find the distribution of all payment statuses across the different tariffs.
/*
This query provides a comprehensive distribution of payment states across all available service packages. 
It utilizes a composite GROUP BY on both tariff names and status types to generate a multi-dimensional summary. 
This report is used to evaluate the financial status of various customer segments and ensure system-wide payment tracking.
*/
SELECT t.NAME AS TARIFF_NAME, m.PAYMENT_STATUS, COUNT(*) AS TOTAL 
FROM MONTHLY_STATS m 
JOIN CUSTOMERS c ON m.CUSTOMER_ID = c.CUSTOMER_ID 
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID 
GROUP BY t.NAME, m.PAYMENT_STATUS;