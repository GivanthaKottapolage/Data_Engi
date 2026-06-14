# XYZ Bank Dataset

**Zero to Data Engineer — Week 02, Day 2 Exercise**

You have been given an export from **XYZ Bank**, a growing financial institution in Sri Lanka. It offers Savings accounts, Fixed Deposits, Credit/Debit Cards, Personal Loans and Micro Loans across **10 branches** and **10 ATMs**. The export comes straight out of the bank's operational systems (core banking, cards, ATM). Your job this week is to load it into PostgreSQL, profile it, clean it, and use it to answer the questions the branch manager keeps asking.

> This data is **synthetic** (computer generated). It does not describe any real person, account, or transaction. Any resemblance to real individuals is coincidental.

---

## 1. What is in this folder

13 CSV files. Each file is one table in the data model.

| File | What one row represents | Rows |
|------|------------------------|------|
| `customers.csv` | One customer | 8,000 |
| `customer_addresses.csv` | One customer address | 8,798 |
| `customer_phones.csv` | One customer phone | 9,466 |
| `accounts.csv` | One bank account | 10,168 |
| `account_ownership.csv` | One customer–account ownership link | 11,178 |
| `cards.csv` | One card | 5,543 |
| `loans.csv` | One loan | 2,401 |
| `loan_repayments.csv` | One loan repayment | 9,598 |
| `transactions.csv` | One transaction | 42,000 |
| `branches.csv` | One branch | 10 |
| `atms.csv` | One ATM | 10 |
| `employees.csv` | One employee | 120 |
| `merchants.csv` | One merchant | 300 |

**Total: ~107,600 rows**

The full XYZ Bank system is much larger (17 schemas, ~47 tables). This is a focused 13-table slice — enough to practise the whole flow end to end.

---

## 2. The questions you are working toward

The branch manager keeps asking four questions the raw systems cannot answer easily. They are your end goal:

1. **Which branch brought in the highest deposits?**
2. **Who is giving out the most loans?**
3. **Are the fixed deposits growing?**
4. **Are the ATMs being used?**

None of these can be answered correctly off the raw data — each one depends on cleaning a specific part of it first. That is the point of the exercise.

---

## 3. How the tables relate

Everything ties back to **customers**, **accounts**, and **branches**.

- A **customer** owns one or more **accounts** (through `account_ownership`, which also supports joint accounts), and can have **addresses**, **phones**, and **loans**
- An **account** belongs to a **branch** and can have **cards**
- Each **loan** has **loan_repayments**
- **Branches** have **employees** and **ATMs**
- **Transactions** tie it together — each one links to at most one account, card, ATM, merchant, employee, and loan

**Foreign keys at a glance:**

| Table | Foreign key column(s) | Points to |
|-------|-----------------------|-----------|
| customer_addresses | `customer_id` | customers |
| customer_phones | `customer_id` | customers |
| accounts | `branch_id` | branches |
| account_ownership | `customer_id`, `account_id` | customers, accounts |
| cards | `account_id` | accounts |
| loans | `customer_id` | customers |
| loan_repayments | `loan_id` | loans |
| employees | `branch_id` | branches |
| atms | `branch_id` | branches |
| transactions | `account_id`, `card_id`, `atm_id`, `merchant_id`, `employee_id`, `loan_id` | accounts, cards, atms, merchants, employees, loans *(all nullable)* |

A transaction links to at most one of each entity, so those foreign keys are nullable on purpose.

---

## 4. Column reference

Each column below maps to the schema you create in section 6.

### customers.csv → `core_banking.customer`
| Column | Type | Notes |
|--------|------|-------|
| `customer_id` | integer | Primary key |
| `customer_no` | text | Unique customer reference |
| `nic_number` | text | National ID — unique; mixes old (9 digits + V) and new (12-digit) formats |
| `first_name` | text | |
| `last_name` | text | |
| `dob` | text | Date of birth — **mixed date formats, some missing or impossible. Loaded as text.** |
| `gender` | text | **Inconsistent encoding (M / Male / male / F …). Standardize it.** |
| `occupation` | text | Free text — inconsistent casing and variants |
| `email` | text | Some missing or placeholder values |

### customer_addresses.csv → `core_banking.customer_address`
| Column | Type | Notes |
|--------|------|-------|
| `address_id` | integer | Primary key |
| `customer_id` | integer | Owner (→ customers) |
| `address_type` | text | e.g. Home / Work — inconsistent encoding |
| `address_line1` | text | |
| `address_line2` | text | Often blank |
| `city` | text | |
| `state` | text | |
| `postal_code` | text | |
| `is_primary` | boolean | A customer may have **more than one** flagged primary — watch this |

### customer_phones.csv → `core_banking.customer_phone`
| Column | Type | Notes |
|--------|------|-------|
| `phone_id` | integer | Primary key |
| `customer_id` | integer | Owner (→ customers) |
| `phone_number` | text | Inconsistent formats |
| `phone_type` | text | e.g. Mobile / Home — inconsistent encoding |
| `is_primary` | boolean | May have more than one primary per customer |

### accounts.csv → `core_banking.account`
| Column | Type | Notes |
|--------|------|-------|
| `account_id` | integer | Primary key |
| `account_number` | text | Unique |
| `balance` | text | **Money — some use thousand separators, some are zero or negative. Loaded as text.** |
| `opening_date` | text | **Mixed date formats, some future-dated. Loaded as text.** |
| `status` | text | Inconsistent encoding (Active / active / A …) |
| `branch_id` | integer | Branch the account belongs to (→ branches) |
| `account_type` | text | **Savings / FD / etc. — inconsistent (FD vs Fixed Deposit vs Fixed). Needed for the FD question.** |

### account_ownership.csv → `core_banking.account_ownership`
| Column | Type | Notes |
|--------|------|-------|
| `customer_id` | integer | Owner (→ customers) — part of composite primary key |
| `account_id` | integer | Account (→ accounts) — part of composite primary key |
| `ownership_start_date` | text | When ownership began; supports joint accounts |

### cards.csv → `cards.card`
| Column | Type | Notes |
|--------|------|-------|
| `card_id` | integer | Primary key |
| `card_number` | text | Unique |
| `account_id` | integer | Account the card is on (→ accounts) |
| `card_type` | text | Credit / Debit — inconsistent encoding |
| `expiry_date` | text | **`MM/YY` and other formats; some already expired. Loaded as text.** |
| `status` | text | Inconsistent encoding |

### loans.csv → `loans.loan`
| Column | Type | Notes |
|--------|------|-------|
| `loan_id` | integer | Primary key |
| `loan_number` | text | Unique |
| `customer_id` | integer | Borrower (→ customers) |
| `amount` | text | **Loan amount — some zero, negative, or missing. Loaded as text.** |
| `interest_rate` | numeric | **Sometimes a percent (12), sometimes a decimal (0.12). Normalize it.** |
| `start_date` | text | Mixed date formats. Loaded as text |
| `loan_type` | text | **Personal / Micro — inconsistent. Needed for the loans question.** |

### loan_repayments.csv → `loans.loan_repayment`
| Column | Type | Notes |
|--------|------|-------|
| `repayment_id` | integer | Primary key |
| `loan_id` | integer | Loan (→ loans) |
| `repayment_date` | text | Mixed formats; some fall **before** the loan start date. Loaded as text |
| `amount` | numeric | Repayment amount |

### transactions.csv → `core_banking.transaction`
| Column | Type | Notes |
|--------|------|-------|
| `transaction_id` | integer | Primary key |
| `transaction_timestamp` | timestamp | When it happened — some future-dated |
| `amount` | numeric | **Some zero or negative** |
| `transaction_type` | text | **Deposit / Withdrawal / … — inconsistent. Needed for the deposits question.** |
| `channel` | text | **ATM / Online / Branch / … — inconsistent. Needed for the ATM question.** |
| `reference_no` | text | |
| `account_id` | integer | → accounts (nullable) |
| `card_id` | integer | → cards (nullable) |
| `atm_id` | integer | → atms (nullable) |
| `merchant_id` | integer | → merchants (nullable) |
| `employee_id` | integer | → employees (nullable) |
| `loan_id` | integer | → loans (nullable) |

### branches.csv → `core_banking.branch`
| Column | Type | Notes |
|--------|------|-------|
| `branch_id` | integer | Primary key |
| `branch_code` | text | Unique |
| `name` | text | Inconsistent casing/whitespace |
| `address` | text | |
| `ifsc_code` | text | Routing code — some missing |

### atms.csv → `channels.atm`
| Column | Type | Notes |
|--------|------|-------|
| `atm_id` | integer | Primary key |
| `atm_code` | text | Unique |
| `branch_id` | integer | Branch it belongs to (→ branches) |

### employees.csv → `core_banking.employee`
| Column | Type | Notes |
|--------|------|-------|
| `employee_id` | integer | Primary key |
| `employee_no` | text | Unique |
| `name` | text | Inconsistent casing |
| `position` | text | Inconsistent labels and abbreviations |
| `branch_id` | integer | Branch (→ branches) |

### merchants.csv → `reference.merchant`
| Column | Type | Notes |
|--------|------|-------|
| `merchant_id` | integer | Primary key |
| `merchant_name` | text | The same name may appear under different IDs |
| `category` | text | Inconsistent casing/variants; some missing |

---

## 5. About the data quality

**This data is intentionally dirty.** That is the exercise. It loads into the schema without errors, but the *values* are messy — exactly like a real production export.

You will find:
- Missing values in many disguises — blanks plus `NULL`, `null`, `N/A`, `NA`, `-`, `None`, and a single space. **Treat them all as missing.**
- The same category written many ways — `gender`, account/card `status`, `transaction_type`, `channel`, `account_type`, `loan_type`, and more
- Dates in several formats (ISO, `DD/MM/YYYY`, `MM-DD-YYYY`, `DD-Mon-YYYY`, `MM/YY` for cards) plus impossible/future dates
- Numbers stored as text — thousand separators in `balance`, zero/negative amounts, and `interest_rate` mixing percent (12) and decimal (0.12)
- Business-rule oddities — more than one "primary" address/phone per customer, expired cards, transactions with no linked entity

**Rule: profile first, decide on cleaning rules, then clean.**

---

## 6. Loading the CSVs into PostgreSQL via DataGrip

> **Before you start:** Make sure PostgreSQL is running and DataGrip shows a green **Successful** connection. If not, check the **Week 01 Prerequisites Setup Guide**.

---

### Step 1 — Create the schemas and tables

Open DataGrip. In the **Database Explorer**, right-click your `postgres` data source and choose **Open Query Console**. Open the provided **`bank_table_create.sql`** and run it.

It creates 5 schemas — `core_banking`, `loans`, `cards`, `channels`, `reference` — and all 13 tables, with primary keys, unique constraints, and foreign keys already in place.

> **Why are dates and money stored as text?**
> Columns like `dob`, `balance`, `opening_date`, loan `amount`, `start_date`, `repayment_date`, and card `expiry_date` arrive in mixed formats. The schema deliberately stores them as `VARCHAR` so the raw text loads without the importer crashing or silently dropping rows. You cast them to real `DATE` / `NUMERIC` types **after** cleaning. (A few columns — `transaction` timestamp/amount, repayment `amount`, `interest_rate` — are already typed, because their values are clean enough to cast on load.)

---

### Step 2 — Import each CSV file

Foreign keys are enforced, so import **in this exact order** — parent tables must be loaded before the child tables that reference them.

| Order | CSV file | Target table |
|-------|----------|--------------|
| 1 | `branches.csv` | `core_banking.branch` |
| 2 | `customers.csv` | `core_banking.customer` |
| 3 | `merchants.csv` | `reference.merchant` |
| 4 | `employees.csv` | `core_banking.employee` |
| 5 | `accounts.csv` | `core_banking.account` |
| 6 | `atms.csv` | `channels.atm` |
| 7 | `customer_addresses.csv` | `core_banking.customer_address` |
| 8 | `customer_phones.csv` | `core_banking.customer_phone` |
| 9 | `account_ownership.csv` | `core_banking.account_ownership` |
| 10 | `cards.csv` | `cards.card` |
| 11 | `loans.csv` | `loans.loan` |
| 12 | `loan_repayments.csv` | `loans.loan_repayment` |
| 13 | `transactions.csv` | `core_banking.transaction` |

**For each file, do the following:**

1. In the **Database Explorer**, expand your connection → `postgres` → the schema for that table (e.g. `core_banking`)
2. Right-click the target table and choose **Import Data from File…**
3. In the file picker, open the `Week 02` data folder and select the CSV
4. In the **Import File** dialog, set these options:

   | Setting | Value |
   |---------|-------|
   | Format | CSV |
   | First row is header | ✅ Yes |
   | Separator | `,` (comma) |
   | Quote character | `"` (double quote) |
   | Encoding | UTF-8 |
   | Null value text | *(leave blank)* |
   | On error | Skip row |

5. Check the **column mapping** at the bottom — every CSV column should map to a table column. There should be no `<unmapped>` entries.
6. Click **Import** and wait for it to finish. `transactions.csv` (42,000 rows) is the only large one and takes a little longer.

**Repeat steps 1–6 for all 13 files, in order.**

---

### Step 3 — Verify the import

Run this in the Query Console to check row counts:

```sql
SELECT 'customer'         AS table_name, COUNT(*) AS rows FROM core_banking.customer
UNION ALL SELECT 'customer_address',  COUNT(*) FROM core_banking.customer_address
UNION ALL SELECT 'customer_phone',    COUNT(*) FROM core_banking.customer_phone
UNION ALL SELECT 'account',           COUNT(*) FROM core_banking.account
UNION ALL SELECT 'account_ownership', COUNT(*) FROM core_banking.account_ownership
UNION ALL SELECT 'transaction',       COUNT(*) FROM core_banking.transaction
UNION ALL SELECT 'branch',            COUNT(*) FROM core_banking.branch
UNION ALL SELECT 'employee',          COUNT(*) FROM core_banking.employee
UNION ALL SELECT 'loan',              COUNT(*) FROM loans.loan
UNION ALL SELECT 'loan_repayment',    COUNT(*) FROM loans.loan_repayment
UNION ALL SELECT 'card',              COUNT(*) FROM cards.card
UNION ALL SELECT 'atm',               COUNT(*) FROM channels.atm
UNION ALL SELECT 'merchant',          COUNT(*) FROM reference.merchant
ORDER BY table_name;
```

Expected row counts:

| Table | Rows |
|-------|------|
| account | 10,168 |
| account_ownership | 11,178 |
| atm | 10 |
| branch | 10 |
| card | 5,543 |
| customer | 8,000 |
| customer_address | 8,798 |
| customer_phone | 9,466 |
| employee | 120 |
| loan | 2,401 |
| loan_repayment | 9,598 |
| merchant | 300 |
| transaction | 42,000 |

**Your loaded counts may be lower than these — and that's expected.** The import skips any row it can't insert — for example, a missing value in a `NOT NULL` column, or a value that breaks a constraint. DataGrip reports how many rows were skipped per file; note those numbers and investigate the rejected rows during profiling — don't try to force the totals to match.

---

### Troubleshooting

| Problem | Fix |
|---------|-----|
| DataGrip says **Connection refused** | PostgreSQL is not running. Windows: open Services → start PostgreSQL. macOS: open Postgres.app. Linux: `sudo service postgresql start` |
| DataGrip says **Password authentication failed** | Wrong password saved in DataGrip. Edit the data source and re-enter it |
| Import fails with a **foreign key** error | You loaded a child table before its parent. Follow the order in Step 2 exactly |
| You see **duplicate key** errors on a re-run | The table still holds data from a previous import. `TRUNCATE` it (e.g. `TRUNCATE core_banking.transaction CASCADE;`) and import again |
| `schema "core_banking" does not exist` | You skipped Step 1. Run `bank_table_create.sql` first |
| Import is very slow or hangs | Go to **Settings → Database → Import/Export** and increase *Batch size* to 5000 |
| Text looks garbled | Encoding issue. Change **Encoding** in the dialog from UTF-8 to `Windows-1252` |

---

## 7. What to do after loading (Bronze → Silver → Gold)

What you have just loaded is your **Bronze** layer — raw and dirty. Cleaning it gives you **Silver**. Aggregating Silver to answer the manager's questions gives you **Gold**.

**Profile (find the problems):**
1. **Count rows per table** — compare against the expected numbers above
2. **Count nulls per column** — remember the disguised nulls (`N/A`, `-`, `None`, …), especially in `gender`, `email`, `dob`, `balance`, and the date columns
3. **List distinct values** of the categorical columns (`gender`, `status`, `transaction_type`, `channel`, `account_type`, `loan_type`) to see how many ways each value is written
4. **Check ranges** — negative/zero balances and amounts, future dates, expired cards
5. **Check business rules** — customers with more than one primary address/phone

**Clean (Silver):** standardize the categories, parse the mixed date formats, normalize numbers (strip thousand separators; make `interest_rate` consistently a decimal), and treat all the missing-value tokens as `NULL`.

**Answer (Gold):** with clean data, tackle the four questions from section 2:
1. **Highest deposits by branch** — needs `transaction_type` standardized and zero/negative amounts handled
2. **Most loans** — needs `loan_type` standardized and the loan `amount` text parsed
3. **FD growth** — needs `account_type` standardized (FD vs Fixed Deposit vs Fixed) and `opening_date` parsed
4. **ATM usage** — needs `channel` standardized

The cleaned tables are the input for later weeks, when you automate this same pipeline and load the results into a cloud warehouse.

---

*Zuu Crew — Machine Learning Academy*
