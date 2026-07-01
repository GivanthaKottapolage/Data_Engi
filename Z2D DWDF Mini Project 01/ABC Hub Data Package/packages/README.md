# ABC Hub Operational Database

This package contains the simulated operational database for ABC Hub, the
entertainment company described in Mini Project 01. Use this data as the
source for Question 8 (the Apache NiFi ETL pipeline into PostgreSQL).

## Contents

- `ddl/operational_schema.sql` — creates all 26 operational tables, with
  primary keys, foreign keys, and a few helpful indexes.
- `data/*.csv` — one CSV file per table, column order matches the DDL exactly.

## Loading the database

1. Create a database:
   ```
   createdb abc_hub_operational
   ```
2. Create the schema:
   ```
   psql -d abc_hub_operational -f ddl/operational_schema.sql
   ```
3. Load each table in this order (parent tables before child tables, so
   foreign keys resolve correctly):

   ```
   country, city, content_type, genre, artist, device, payment_method,
   support_category, courier, warehouse, subscription_plan,
   customer, customer_address, customer_subscription,
   content, content_genre, content_artist,
   inventory_item, streaming_session, rental, delivery,
   payment, review, wishlist, support_ticket, recommendation
   ```

   For each table:
   ```
   psql -d abc_hub_operational -c "\copy <table_name> FROM 'data/<table_name>.csv' WITH (FORMAT csv, HEADER true)"
   ```

## A note on data quality

This is real-world-style operational data: most of it is clean, but you will
encounter some missing optional fields, inconsistent text casing, a handful
of duplicate-looking records, and a few values that break expected business
rules (for example, a watch completion percentage slightly above 100%, or a
late fee that is negative). Part of Question 8, Task 2 is to detect and
handle exactly this kind of issue in your NiFi transformation stage — treat
it as you would real operational data, not as a mistake in the dataset.

## Assumptions baked into this dataset

- The data covers roughly 12 months of operational history.
- Content types are split into streamable (Movie, TV Series, Documentary,
  Music) and rentable (Movie, Music, Book, Video Game); Movies and Music
  appear in both streaming and physical-rental form, matching the scenario.
- Subscription payments are generated monthly for each active subscription
  period; rental payments are generated once per rental.
