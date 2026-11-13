/* ============================================================================
   DEBIT & CREDIT BANK ANALYTICS — FINAL MYSQL WORKBENCH SCRIPT
   Purpose: Verify imported table, validate data, and calculate 3 basic + 5 main KPIs.

   EXPECTED DATABASE: debit_credit_analytics
   EXPECTED TABLE:    debit_credit_transactions
   EXPECTED COLUMNS:  Customer ID, Customer Name, Account Number, Transaction Date,
                      Transaction Type, Amount, Balance, Description, Branch,
                      Transaction Method, Currency, Bank Name

   BEFORE RUNNING:
   - Import your CSV into the database/table above using Table Data Import Wizard.
   - If your table has a different name, replace it in this script.
   - Run one section at a time so each result grid is easy to present.
   ============================================================================ */

-- 0. DATABASE / TABLE VERIFICATION
CREATE DATABASE IF NOT EXISTS debit_credit_analytics;
USE debit_credit_analytics;
SHOW TABLES;
DESCRIBE debit_credit_transactions;
SELECT COUNT(*) AS total_transactions FROM debit_credit_transactions; -- Expected: 100000
SELECT * FROM debit_credit_transactions LIMIT 10;

-- 1. MISSING / BLANK VALUE CHECKS
SELECT
 SUM(`Customer ID` IS NULL OR TRIM(`Customer ID`)='') AS missing_customer_id,
 SUM(`Customer Name` IS NULL OR TRIM(`Customer Name`)='') AS missing_customer_name,
 SUM(`Account Number` IS NULL OR TRIM(`Account Number`)='') AS missing_account_number,
 SUM(`Transaction Date` IS NULL) AS missing_transaction_date,
 SUM(`Transaction Type` IS NULL OR TRIM(`Transaction Type`)='') AS missing_transaction_type,
 SUM(`Amount` IS NULL) AS missing_amount,
 SUM(`Balance` IS NULL) AS missing_balance,
 SUM(`Description` IS NULL OR TRIM(`Description`)='') AS missing_description,
 SUM(`Branch` IS NULL OR TRIM(`Branch`)='') AS missing_branch,
 SUM(`Transaction Method` IS NULL OR TRIM(`Transaction Method`)='') AS missing_method,
 SUM(`Currency` IS NULL OR TRIM(`Currency`)='') AS missing_currency,
 SUM(`Bank Name` IS NULL OR TRIM(`Bank Name`)='') AS missing_bank_name
FROM debit_credit_transactions;

-- 2. TRANSACTION TYPE VALIDATION
SELECT `Transaction Type`, COUNT(*) AS record_count
FROM debit_credit_transactions
GROUP BY `Transaction Type`
ORDER BY record_count DESC;
SELECT COUNT(*) AS invalid_transaction_types
FROM debit_credit_transactions
WHERE `Transaction Type` IS NULL OR UPPER(TRIM(`Transaction Type`)) NOT IN ('DEBIT','CREDIT');

-- 3. AMOUNT VALIDATION
SELECT SUM(`Amount` IS NULL) AS null_amounts,
       SUM(`Amount` < 0) AS negative_amounts,
       SUM(`Amount` = 0) AS zero_amounts,
       MIN(`Amount`) AS minimum_amount,
       MAX(`Amount`) AS maximum_amount
FROM debit_credit_transactions;

-- 4. EXACT DUPLICATE ROW CHECK
SELECT COALESCE(SUM(copies - 1),0) AS duplicate_rows_beyond_first
FROM (
 SELECT COUNT(*) AS copies
 FROM debit_credit_transactions
 GROUP BY `Customer ID`,`Customer Name`,`Account Number`,`Transaction Date`,
          `Transaction Type`,`Amount`,`Balance`,`Description`,`Branch`,
          `Transaction Method`,`Currency`,`Bank Name`
 HAVING COUNT(*) > 1
) AS duplicate_groups;

-- 5. DATE RANGE AND MONTH COVERAGE
SELECT MIN(`Transaction Date`) AS earliest_date,
       MAX(`Transaction Date`) AS latest_date,
       COUNT(DISTINCT DATE_FORMAT(`Transaction Date`,'%Y-%m')) AS months_present
FROM debit_credit_transactions;
SELECT DATE_FORMAT(`Transaction Date`,'%Y-%m') AS transaction_month,
       COUNT(*) AS record_count
FROM debit_credit_transactions
GROUP BY DATE_FORMAT(`Transaction Date`,'%Y-%m')
ORDER BY transaction_month;

-- 6. BUSINESS-RULE CHECK: SALARY DEPOSIT CLASSIFIED AS DEBIT
-- Investigate; do not automatically change the transaction type.
SELECT `Description`,`Transaction Type`,COUNT(*) AS transaction_count,
       ROUND(SUM(`Amount`),2) AS total_amount
FROM debit_credit_transactions
WHERE LOWER(TRIM(`Description`))='salary deposit'
GROUP BY `Description`,`Transaction Type`
ORDER BY `Transaction Type`;

-- 7. BUSINESS-RULE CHECK: DEBIT AMOUNT GREATER THAN BALANCE
-- This is not necessarily an error until the meaning/timing of Balance is confirmed.
SELECT COUNT(*) AS debit_amount_greater_than_balance
FROM debit_credit_transactions
WHERE UPPER(TRIM(`Transaction Type`))='DEBIT' AND `Amount` > `Balance`;
SELECT `Transaction Date`,`Account Number`,`Transaction Type`,`Amount`,`Balance`,`Description`
FROM debit_credit_transactions
WHERE UPPER(TRIM(`Transaction Type`))='DEBIT' AND `Amount` > `Balance`
LIMIT 50;

-- 8. DECEMBER 2024 COVERAGE
SELECT DATE(`Transaction Date`) AS transaction_date, COUNT(*) AS record_count
FROM debit_credit_transactions
WHERE `Transaction Date` >= '2024-12-01' AND `Transaction Date` < '2025-01-01'
GROUP BY DATE(`Transaction Date`)
ORDER BY transaction_date;

/* ============================================================================
   BASIC KPI 1 — TOTAL TRANSACTIONS
   ============================================================================ */
SELECT COUNT(*) AS total_transactions
FROM debit_credit_transactions;

/* ============================================================================
   BASIC KPI 2 — TOTAL DEBIT AMOUNT
   ============================================================================ */
SELECT ROUND(COALESCE(SUM(`Amount`),0),2) AS total_debit_amount
FROM debit_credit_transactions
WHERE UPPER(TRIM(`Transaction Type`))='DEBIT';

/* ============================================================================
   BASIC KPI 3 — TOTAL CREDIT AMOUNT
   ============================================================================ */
SELECT ROUND(COALESCE(SUM(`Amount`),0),2) AS total_credit_amount
FROM debit_credit_transactions
WHERE UPPER(TRIM(`Transaction Type`))='CREDIT';

/* ============================================================================
   MAIN KPI 4 — NET TRANSACTION FLOW (CREDITS MINUS DEBITS)
   ============================================================================ */
SELECT ROUND(
 COALESCE(SUM(CASE WHEN UPPER(TRIM(`Transaction Type`))='CREDIT' THEN `Amount` ELSE 0 END),0)
 - COALESCE(SUM(CASE WHEN UPPER(TRIM(`Transaction Type`))='DEBIT' THEN `Amount` ELSE 0 END),0),2
) AS net_transaction_flow
FROM debit_credit_transactions;

/* ============================================================================
   MAIN KPI 5 — AVERAGE TRANSACTION VALUE
   ============================================================================ */
SELECT ROUND(AVG(`Amount`),2) AS average_transaction_value
FROM debit_credit_transactions;

/* ============================================================================
   MAIN KPI 6 — DEBIT-TO-CREDIT AMOUNT RATIO
   Ratio = total debit amount / total credit amount.
   ============================================================================ */
SELECT ROUND(
 SUM(CASE WHEN UPPER(TRIM(`Transaction Type`))='DEBIT' THEN `Amount` ELSE 0 END)
 / NULLIF(SUM(CASE WHEN UPPER(TRIM(`Transaction Type`))='CREDIT' THEN `Amount` ELSE 0 END),0),4
) AS debit_to_credit_amount_ratio
FROM debit_credit_transactions;

/* ============================================================================
   MAIN KPI 7 — MONTHLY TRANSACTION TREND
   ============================================================================ */
SELECT DATE_FORMAT(`Transaction Date`,'%Y-%m') AS transaction_month,
       UPPER(TRIM(`Transaction Type`)) AS transaction_type,
       COUNT(*) AS transaction_count,
       ROUND(SUM(`Amount`),2) AS total_amount
FROM debit_credit_transactions
GROUP BY DATE_FORMAT(`Transaction Date`,'%Y-%m'),UPPER(TRIM(`Transaction Type`))
ORDER BY transaction_month,transaction_type;

/* ============================================================================
   MAIN KPI 8 — TOP TRANSACTION CATEGORIES BY TOTAL AMOUNT
   ============================================================================ */
SELECT `Description` AS transaction_category,
       COUNT(*) AS transaction_count,
       ROUND(SUM(`Amount`),2) AS total_amount
FROM debit_credit_transactions
GROUP BY `Description`
ORDER BY total_amount DESC
LIMIT 10;

-- END OF SCRIPT. Source review flags: Salary Deposit/Debit, debit amount > Balance,
-- and December coverage ending on 2024-12-01. Investigate/document; do not auto-correct.
