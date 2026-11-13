# Bank Debit & Credit Transaction Analytics

An end-to-end banking analytics project that validates and analyzes **100,000 debit and credit transactions** (January to December 2024, INR) across six banks, using SQL for data checks and KPIs and three dashboards (Excel, Power BI and Tableau) for reporting.

## Business Questions
- How much money flows in (credits) versus out (debits), and what is the net position?
- How do transaction volume and value change month by month?
- Which transaction categories and payment methods drive the most value?
- Can the data be trusted? What quality issues need to be flagged before reporting?

## Tools Used
| Area | Tools |
|---|---|
| Data validation & KPIs | SQL (MySQL Workbench) |
| Dashboards | Excel (PivotTables, slicers), Power BI, Tableau |

## Data
A single transactions table with 12 columns: Customer ID, Customer Name, Account Number, Transaction Date, Transaction Type, Amount, Balance, Description, Branch, Transaction Method, Currency and Bank Name.

> This is a practice dataset with synthetic customer details, not real bank data.

## SQL Work
The script runs in two parts: data validation, then KPIs.

**Validation checks:** missing or blank values, transaction type values, amount ranges, duplicate rows, date coverage, and two business-rule checks (salary deposits marked as debits, and debits larger than the balance).

**KPIs:**
1. Total transactions
2. Total debit amount
3. Total credit amount
4. Net transaction flow (credits minus debits)
5. Average transaction value
6. Debit-to-credit amount ratio
7. Monthly transaction trend
8. Top transaction categories by total amount

Script: [`Debit_Credit_Analytics_Final_Executable.sql`](Debit_Credit_Analytics_Final_Executable.sql)

## Dashboards
| Tool | File |
|---|---|
| Excel | [`Debit_and_Credit_Dashboard.xlsx`](Debit_and_Credit_Dashboard.xlsx) |
| Power BI | [`Bank_Credit_and_Debit_Dashboard.pbix`](Bank_Credit_and_Debit_Dashboard.pbix) |
| Tableau | [`Credit_and_Debit_Card_Tableau_Dashboard.twbx`](Credit_and_Debit_Card_Tableau_Dashboard.twbx) |

## Key Findings
- **100,000 transactions**: 50,028 credits and 49,972 debits.
- **Total credits are about ₹127.60 million and total debits about ₹127.28 million**, a net inflow of roughly ₹0.32 million. The debit-to-credit ratio is 0.9975, so money in and out are almost balanced.
- **The average transaction value is ₹2,548.84**, with amounts ranging from ₹100.10 to ₹4,999.90.
- **Transactions are spread evenly across categories.** Utility Bill Payment is the top category by value at about ₹26.04 million, but all ten categories fall between ₹24.96 million and ₹26.04 million.
- **Monthly volume is steady** at roughly 8,600 to 9,300 transactions from January to November.

## Data Quality Notes
- No missing values, no duplicate rows, and no zero or negative amounts.
- **December 2024 has only 305 records** (data ends on 1 December 2024), so December should not be compared with other months.
- **4,932 "Salary Deposit" transactions are marked as Debit**, which is unusual for a deposit. This is flagged for investigation and was not changed.
- **11,013 debit transactions are larger than the recorded balance.** Whether this is an error depends on when the balance was recorded, so it is flagged and not corrected.

## Repository Structure
```
bank-debit-credit-analytics/
├── README.md
├── Debit_Credit_Analytics_Final_Executable.sql
├── Debit_and_Credit_Dashboard.xlsx
├── Bank_Credit_and_Debit_Dashboard.pbix
└── Credit_and_Debit_Card_Tableau_Dashboard.twbx
```

## How to Use
1. Import the transactions data into MySQL as `debit_credit_analytics.debit_credit_transactions` and run the SQL script one section at a time.
2. Open the Excel workbook and use the slicers on the Dashboard sheet.
3. Open the `.pbix` in Power BI Desktop and the `.twbx` in Tableau Desktop or Tableau Public.

## Author
**Vaibhav Kamble**, Junior Data Analyst

[LinkedIn](https://www.linkedin.com/in/vaibhav-kamble-4a4a34416)
