# Week 02 — Warehouse Architecture & Data Modeling

Zero to Data Engineer — Week 02. Load XYZ Bank's operational export into PostgreSQL (the source/OLTP side), then model the same business facts four classic ways — Inmon, Kimball, Data Vault, and One Big Table — so you can feel the trade-offs first-hand.

## What's here

| File | What it is |
|------|------------|
| `bank_table_create.sql` | The **source (OLTP) schema** — `core_banking`, `loans`, `cards`, `channels`, `reference`. Run this first, then load the dataset into it. |
| `inmon.sql` | **Inmon** — a normalized enterprise data warehouse model (`inmon` schema). |
| `kimball.sql` | **Kimball** — a dimensional model with dimension + fact tables (`kimball` schema). |
| `data_vault.sql` | **Data Vault** — hubs, links, and satellites (`data_vault` schema). |
| `OBT.sql` | **One Big Table** — a single wide, denormalized analytics table (`obt` schema). |
| `week-02-homework-banking-kpi.pdf` | This week's assignment. |
| `Dataset/` | The 13 CSV files + a detailed README explaining the data and how to import it. |

The four modeling scripts build their tables in a separate `bank_olap` database — the analytics (OLAP) side — so you can compare them against the operational source side by side.

## Getting the files (clone the repo)

This is a **private** repo. You must be signed in to the GitHub account that was added to the bootcamp students team.

```bash
git clone https://github.com/zuucrew/dw-fundamentals-bootcamp.git
cd "dw-fundamentals-bootcamp/Week 02"
```

When prompted, log in with your GitHub account (a browser window opens, or paste a Personal Access Token as the password). If you don't have Git installed, get it from https://git-scm.com/downloads.

> Prefer no command line? On the repo page click the green **Code** button → **Download ZIP**, then unzip it.

## How to start

1. Open the [Dataset README](Dataset/README.md) and follow it to run `bank_table_create.sql` and load the 13 CSVs into PostgreSQL.
2. Profile and clean the data (the values are intentionally dirty — see the Dataset README).
3. Explore the four modeling approaches: run `inmon.sql`, `kimball.sql`, `data_vault.sql`, and `OBT.sql`, and compare how each one organizes the same facts to answer the bank's business questions.
4. Complete `week-02-homework-banking-kpi.pdf`.

---

*Zuu Crew — Machine Learning Academy*
