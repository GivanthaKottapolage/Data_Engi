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
├── Week 03/                  Basic Python ETL: OLTP → OLAP
│   ├── README.md             Basic Python ETL demo guide
│   └── basic_etl/            ETL scripts (config, db, main) + sql/ models
├── Week 04/                  Star schema: building facts & dimensions
│   ├── README.md             Week guide
│   ├── fact_and_dim.sql      Schema (DDL): dimension + fact tables
│   └── ingest_dim_and_fact.sql  Load (DML): populate dims & facts
├── Week 07/                  Airflow orchestration, Bronze layer & SCDs
│   ├── README.md             Week guide
│   ├── bronze_layer.sql      Bronze (DDL): 13 landing tables
│   ├── SCD.sql               SCD Type 0–4 dimension designs
│   └── banking-airflow/      Airflow project
│       └── dags/             DAGs + sql/bronze extracts + utils helpers
└── Week 08/                  Medallion layers, SCDs & incremental loads
    ├── bank_oltp_new.sql     Source (OLTP) schema, now with audit columns
    ├── bronze_layer_medallion.sql  Bronze (DDL): raw landing tables
    ├── silver_layer_medallion.sql  Silver (DDL): cleaned & conformed tables
    ├── banking-airflow/      Airflow project
    │   └── dags/             Full-load, incremental & silver DAGs + sql/ + utils/
    └── xyz_bank_scd_student/ XYZ Bank core banking extract, one month apart
        ├── README.md         Dataset guide: tables, row counts, load order
        ├── day1_extract/     System state as of 01 June 2025 (13 CSVs)
        └── day2_extract/     System state as of 01 July 2025 (13 CSVs)
```

More weeks are added here as the bootcamp progresses. Start with **[Week 01](Week%2001/README.md)**, then **[Week 02](Week%2002/README.md)**, then **[Week 03](Week%2003/README.md)**, then **[Week 04](Week%2004/README.md)**, then **[Week 07](Week%2007/README.md)**, then **[Week 08](Week%2008/xyz_bank_scd_student/README.md)**.

## Catch-up Sessions

- **[Catch-up Session - Apache NiFi](Catch-up%20Session%20-%20Apache%20NiFi/README.md)** — hands-on data ingestion with Apache NiFi: 12 flows from core routing to enterprise performance tuning, plus sample datasets.

## Mini Projects

- **[Z2D DWDF Mini Project 01](Z2D%20DWDF%20Mini%20Project%2001/)** — *ABC Hub*: design and build an analytical system from a simulated entertainment-company operational database (27-table dataset + operational schema DDL). Start with the project brief PDF, then follow the [data package README](Z2D%20DWDF%20Mini%20Project%2001/ABC%20Hub%20Data%20Package/packages/README.md) to load the source data.
- **[Z2D DWDF Mini Project 02](Z2D%20DWDF%20Mini%20Project%2002/)** — *ABC Hub: Evolving the Data Platform*: a direct continuation of Mini Project 01 — keep the same business scenario, data model and database design, and grow them into a production-ready platform. Covers Airflow fundamentals, an evidence-based NiFi vs Airflow decision, Medallion architecture, SCDs, and incremental, idempotent processing with retries and backfill. Brief only — build on your Mini Project 01 solution and reuse its data package.

## Capstone Project

- **[Z2D DWDF Capstone Project](Z2D%20DWDF%20Capstone%20Project/)** — *PulseTrack*: the end-to-end capstone — build a warehouse over a multi-source ad-tech platform covering advertisers, partners, campaigns, creatives, impressions, clicks, conversions, attribution touchpoints and revenue adjustments. Three source shapes to integrate: 11 raw relational extracts (~774,000 rows), document-shaped MongoDB collections, and a Kafka-style topic dump with at-least-once duplicates, malformed writes and mid-stream schema evolution. The data is deliberately dirty and the dirt is the exercise. Start with the project brief PDF, then follow the [data guide](Z2D%20DWDF%20Capstone%20Project/DE01Capstone/PulseTrack-Data-Guide.pdf) and the [stream notes](Z2D%20DWDF%20Capstone%20Project/DE01Capstone/stream/README_topic.md) to load the source data.

---

*Zuu Crew — Machine Learning Academy*
