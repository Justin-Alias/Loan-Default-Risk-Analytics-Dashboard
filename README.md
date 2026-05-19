# 🏦 Loan Default Risk — Analytics Dashboard

<div align="center">

![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-4479A1?style=for-the-badge&logo=databricks&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Power Query](https://img.shields.io/badge/Power_Query-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)

*Full-stack BI project — SQL Server ingestion, Power BI dataflow, DAX modelling, incremental refresh, and a 3-page risk intelligence dashboard built to help bank officials make smarter lending decisions.*

</div>

---

## 📋 Project Overview

This project delivers an end-to-end loan risk analytics solution built on a **255,347-row real-world loan dataset**. It covers every layer of a production BI pipeline: local SQL Server setup, secure user access, a Power BI dataflow with scheduled refresh, DAX measure modelling, and a published 3-page interactive report — complete with incremental refresh configured for operational use.

**Business Goal:** Equip bank officials with a data-driven tool to assess borrower risk and make informed loan approval decisions.

---

## 🔄 End-to-End Pipeline

```
Loan_default.csv (255,347 rows)
         │
         ▼
  Local SQL Server (SSMS)
  └─ Database: Loan
  └─ Table: dbo.Loan_default
  └─ User login: data_user (db_datareader role)
         │
         ▼
  Power BI Dataflow
  └─ Connected to SQL Server
  └─ Scheduled daily refresh
         │
         ▼
  Power BI Desktop
  └─ Power Query: clean, validate, transform
  └─ DAX: calculated columns + measures table
  └─ Incremental Refresh configured
         │
         ▼
  Power BI Service (Workspace)
  └─ Report published
  └─ Semantic model refresh: daily (+1.5 hrs after dataflow)
```

---

## 🗄️ SQL Server Setup

The `Loan` database was created on a local SQL Server instance and configured with a dedicated read-only user for Power BI connectivity:

```sql
-- Create database and select it
CREATE DATABASE Loan;
USE Loan;

-- Create a dedicated login and user for Power BI
CREATE LOGIN data_user WITH PASSWORD = '****';
CREATE USER data_user FOR LOGIN data_user;

-- Grant read-only access
ALTER ROLE db_datareader ADD MEMBER data_user;

-- Verify data load
SELECT * FROM [dbo].[Loan_default];
```

> A least-privilege approach was applied — `data_user` is granted only `db_datareader` permissions, restricting access to read-only queries.

---

## 📂 Dataset

**File:** `Loan_default.csv`
**Rows:** 255,347 loan records

| Column | Type | Description |
|---|---|---|
| `LoanID` | String | Unique loan identifier |
| `Age` | Integer | Borrower age at loan issuance |
| `Income` | Decimal | Annual borrower income |
| `LoanAmount` | Decimal | Total approved loan amount |
| `CreditScore` | Integer | Creditworthiness score (300–850) |
| `MonthsEmployed` | Integer | Tenure at current employer (months) |
| `NumCreditLines` | Integer | Number of active credit lines |
| `InterestRate` | Decimal | Annual percentage rate (APR) |
| `LoanTerm` | Integer | Repayment period (months) |
| `DTIRatio` | Decimal | Debt-to-Income ratio |
| `Education` | Category | Highest education level completed |
| `EmploymentType` | Category | Full-Time, Part-Time, Self-Employed, Unemployed |
| `MaritalStatus` | Category | Single, Married, Divorced |
| `HasMortgage` | Boolean | Existing mortgage (Yes/No) |
| `HasDependents` | Boolean | Has dependents (Yes/No) |
| `LoanPurpose` | Category | Home, Auto, Business, Education, Debt Consolidation, Other |
| `HasCoSigner` | Boolean | Co-signer present (Yes/No) |
| `Default` | Boolean | Loan defaulted (1 = Yes, 0 = No) |
| `Loan Date` | Date | Loan issuance date (DD/MM/YYYY) |

---

## 🔧 Data Transformation

### Power Query — Cleaning & Validation

| Task | Action |
|---|---|
| Data types | Assigned correct types to all 19 columns |
| Date parsing | Standardized `Loan Date` to a proper `Date` type |
| Null handling | Validated and addressed null/blank values across key fields |
| Duplicates | Checked and removed duplicate records |
| DateTime column | Added a `DateTime` field to support incremental refresh requirements |

### DAX — Calculated Columns & Measures

A dedicated **Measures Table** was created to organize all DAX logic cleanly:

| Measure / Column | Type | Description |
|---|---|---|
| `Year` | Calculated Column | Extracted year from `Loan Date` for time-series analysis |
| `Loan Amount By Purpose` | Measure | `SUMX` aggregation of loan amounts grouped by purpose |
| `Average Income by Employment Type` | Measure | `AVERAGEX` of income segmented by employment category |
| `YOY Loan Amount Change` | Measure | Year-over-year variance in total loan volume |
| `YOY Default Loan Amount Change` | Measure | Year-over-year variance in defaulted loan amounts |
| `YTD Loan Amount` | Measure | Year-to-date cumulative loan amount |
| `Default Rate %` | Measure | Percentage of loans that defaulted within a segment |

---

## 📊 Dashboard — 3-Page Report

### Page 1 — Loan Default & Overview

> High-level snapshot of loan volume, default rates, and income patterns across the portfolio.

| Chart | Type | Insight |
|---|---|---|
| Loan Amount by Purpose | Bar Chart | Breakdown of total lending by loan purpose |
| Average Income by Employment Type | Bar Chart | Income profile across employment categories |
| Default Rate % by Employment Type | Column Chart | Which employment types carry the highest default risk |
| Average Loan Amount by Age Group | Line / Bar | Lending exposure by borrower age segment |
| Default Rate % by Year | Line Chart | Historical trend of default rates over time |

---

### Page 2 — Applicant Demographics & Financial Profile

> Deep-dive into borrower characteristics — credit health, age, education, and household profile.

| Chart | Type | Insight |
|---|---|---|
| Median Loan Amount by Credit Score Category | Bar Chart | Loan sizing vs. credit health tiers |
| Avg Loan Amount (High Credit) by Age Group & Marital Status | Clustered Bar | Lending patterns for low-risk borrowers |
| Total Loan (Adults) by Credit Score Bin | Histogram | Credit score distribution across adult borrowers |
| Total Loan (Middle-Aged Adults) by Mortgage/Dependents | Stacked Bar | Financial obligations impact on loan volume |
| Number of Loans by Education Type | Donut / Bar | Loan count segmented by education level |

---

### Page 3 — Financial Risk Metrics

> Advanced risk intelligence — year-over-year trends, time-intelligence measures, and decomposition analysis.

| Chart | Type | Insight |
|---|---|---|
| YOY Loan Amount Change by Year | Line Chart | Annual growth or contraction in total lending |
| YOY Default Loan Amount Change by Year | Line Chart | Trending direction of default exposure |
| YTD Loan Amount by Credit Score Bins & Marital Status | Matrix / Bar | Current-year lending segmented by risk and demographics |
| Decomposition Tree — Loan Amount by Income Bracket & Employment Type | Decomposition Tree | Drill-down root-cause view of loan concentration |

---

## 🔁 Refresh & Scheduling

| Layer | Schedule | Details |
|---|---|---|
| **Dataflow** (SQL Server → Power BI) | Daily | Pulls latest data from `dbo.Loan_default` |
| **Semantic Model** (Report dataset) | Daily (+1.5 hrs) | Refreshes 1.5 hours after dataflow completes to ensure data availability |
| **Incremental Refresh** | Rolling window | Refreshes the past **10 days** of data; retains the past **5 years** of history |

> Incremental refresh required adding a `DateTime` column to the dataset to satisfy Power BI's `RangeStart` / `RangeEnd` parameter requirements.

---

## 📁 Project Files

| File | Description |
|---|---|
| `Loan_default.csv` | Source dataset — 255,347 loan records across 19 fields |
| `SQL Queries/SQLQuery1.sql` | Database setup, user creation, and role assignment |
| `Loans.pbix` | Power BI report — dataflow connection, DAX model, and 3-page dashboard |
| `Description of Dataset data & Project.txt` | Project scope, column definitions, and step-by-step walkthrough |

---

## 🛠️ Technologies

| Tool | Purpose |
|---|---|
| **SQL Server Management Studio (SSMS)** | Local database creation, data ingestion, and user access management |
| **T-SQL** | Database setup, login creation, and role-based access control |
| **Power BI Dataflow** | Cloud-based data ingestion layer with scheduled refresh |
| **Power BI Desktop** | Report authoring, DAX modelling, and dashboard design |
| **Power Query (M)** | Data cleaning, type enforcement, and transformation |
| **DAX** | Calculated columns, measures, time-intelligence, and YOY logic |
| **Power BI Service** | Workspace publishing, incremental refresh configuration, and semantic model scheduling |

---

<div align="center">
<sub>Built to demonstrate a production-grade BI pipeline — from raw CSV ingestion through to a scheduled, incrementally-refreshed loan risk dashboard.</sub>
</div>
