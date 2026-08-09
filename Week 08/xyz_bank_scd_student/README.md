# XYZ Bank — Core Banking Data Extract

This is an export from XYZ Bank's core banking system, covering customers, accounts,
branches, employees, cards, ATMs, merchants, loans, and transactions.

You have been given **two extracts**, taken about a month apart:

| Folder | Represents |
|---|---|
| `day1_extract/` | System state as of **01 June 2025** |
| `day2_extract/` | System state as of **01 July 2025** |

This is intentional. Between the two dates, the bank kept running — new customers
joined, addresses and phone numbers were updated, employees got promoted or
transferred, accounts changed status, cards were blocked or reissued, and new
transactions and loan repayments were recorded.

Your job is not just to load a table and overwrite it. It's to build a pipeline
that can tell you **what changed, and when** — so a query like "what was this
customer's occupation on 15 June?" or "when did this account go dormant?" can
actually be answered later, even after a third or fourth extract arrives.

Every table carries `created_at`, `updated_at`, `created_by`, and `updated_by`
columns. `updated_at` is your signal for what changed between the two extracts.

## Tables

| Schema | Table | day1 rows | day2 rows |
|---|---|---:|---:|
| core_banking | customer | 8,200 | 8,450 |
| core_banking | customer_address | 9,416 | 9,711 |
| core_banking | customer_phone | 9,840 | 10,140 |
| core_banking | branch | 32 | 33 |
| core_banking | employee | 160 | 172 |
| core_banking | account | 11,395 | 11,832 |
| core_banking | account_ownership | 11,946 | 12,399 |
| loans | loan | 1,900 | 1,980 |
| loans | loan_repayment | 24,420 | 25,253 |
| cards | card | 9,155 | 9,530 |
| channels | atm | 95 | 98 |
| reference | merchant | 550 | 590 |
| core_banking | transaction | 22,891 | 26,391 |

Column definitions match `bank_oltp_new.sql` exactly — load each extract straight
into that schema.

## Load order

Respect foreign keys in this order: `branch` → `employee` → `customer` →
`customer_address` / `customer_phone` → `account` → `account_ownership` →
`card` → `atm` → `merchant` → `loan` → `loan_repayment` → `transaction`.

## A note on data quality

This is a real extract from an operational system, not a curated report — expect
the usual: inconsistent casing in a few free-text fields, some optional fields
left blank, a couple of different phone number formats. Profile it before you
build on it.

---
*Zuu Crew, Machine Learning Academy.*
