# Zero to Data Engineer — Bootcamp 01
## Data Warehouse Design Fundamentals

Beginner-level foundations for organizing data in a reliable, scalable way. Over this bootcamp you'll go from raw, messy data to clean, query-ready analytical systems — the foundation every modern data platform is built on.

> Part of the **Zero to Data Engineer Specialization** (Bootcamp 1 of 3 → *Foundations*).

---

## What you'll cover

- **SQL mastery for analytics** — from basics to joins, CTEs, window functions, and performance
- **Dimensional data modeling** — fact & dimension tables, star schema
- **Data warehousing** — OLTP vs OLAP, the medallion approach (raw → cleaned → analytics)
- **Slowly Changing Dimensions (SCD)** — tracking how data changes over time
- **ETL / ELT pipeline development** — extract, clean, transform, and load
- **Data quality & profiling** — handling missing, duplicate, and inconsistent data
- **KPI systems & BI integration** — turning models into business answers and dashboards
- **Build analytical systems from raw data** — end to end

## Tools

`PostgreSQL` · `SQL` · `DataGrip` · `dbt` · BI tools (Power BI / Tableau)

## Format

- ⏱️ **10 weeks**, taught in Sinhala (medium)
- 🛠️ **2 mini projects** based on real industry scenarios
- 🎓 **1 end-to-end capstone project**
- ⚡ **Mini hackathon** to apply everything you've learned

We teach **WHY** a technology exists, **HOW** it solves real problems, and **WHEN** to use it — architecture thinking over tool memorization.

---

## Repository structure

```
.
├── Week 01/                  Loading & profiling: get messy data into PostgreSQL
│   ├── README.md             Week guide
│   ├── social_media_table_create.sql  Schema + tables
│   ├── tutorial 1.sql        In-class SQL walkthrough
│   ├── Homework Z2D C1 W1.pdf Weekly assignment
│   └── Dataset/              The week's CSV dataset + its README
├── Week 02/                  Warehouse architecture & data modeling (XYZ Bank)
│   ├── README.md             Week guide
│   ├── bank_table_create.sql Source (OLTP) schema
│   ├── inmon.sql             Inmon normalized EDW model
│   ├── kimball.sql           Kimball dimensional model
│   ├── data_vault.sql        Data Vault model
│   ├── OBT.sql               One Big Table model
│   ├── week-02-homework-banking-kpi.pdf  Weekly assignment
│   └── Dataset/              The week's CSV dataset + its README
└── Week 03/                  Basic Python ETL: OLTP → OLAP
    ├── README.md             Basic Python ETL demo guide
    └── basic_etl/            ETL scripts (config, db, main) + sql/ models
```

More weeks are added here as the bootcamp progresses. Start with **[Week 01](Week%2001/README.md)**, then **[Week 02](Week%2002/README.md)**, then **[Week 03](Week%2003/README.md)**.

---

*Zuu Crew — Machine Learning Academy*
