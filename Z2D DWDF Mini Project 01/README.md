# Z2D DWDF Mini Project 01 — ABC Hub

| File | What it is |
|---|---|
| `Z2D DWDF Mini Project 01 ABC Hub v2 final.pdf` | The project brief. Start here. |
| `ER mini project 1 .pdf` | ER diagram for the ABC Hub operational database. |
| `ABC Hub Data Package/packages/` | The operational (source) database: DDL + 26 CSV files. |

---

## Dataset update — 22 August 2026

**The data package has been replaced. If you downloaded it before this
date, re-download and reload it.**

### What changed

Every one of the 26 tables now has two extra columns at the end:

```
created_at   TIMESTAMP NOT NULL
updated_at   TIMESTAMP NOT NULL
```

**Nothing else changed.** All 98,700 rows are otherwise identical to the
version you already have — same tables, same row counts, same values, same
column order. Only the two new columns were appended.

### Why we did this

Mini Project 02 asks you to evolve this same ABC Hub platform into a
production-style pipeline: Medallion architecture, SCD handling, and
**incremental, idempotent loads**. An incremental load needs a way to ask
the source "what changed since last time?" — that is the watermark pattern
you have been using since Week 07:

```sql
WHERE created_at > '{{ last_watermark }}'
   OR updated_at > '{{ last_watermark }}'
```

The original ABC Hub database had no such columns, so there was no way to
run that pattern against it — every load would have had to be a full
reload. These audit columns close that gap and bring MP01's dataset in
line with the banking dataset used in the weekly Airflow sessions.

They are also simply how real operational systems work: a row records when
it was created and when it was last touched.

### What the timestamps actually mean

They are derived from each row's own business dates, not randomly
assigned, so they behave the way real audit columns do:

- **Lookup tables** (country, city, genre, device, …) get a platform-setup
  date — static master data, so `updated_at` matches `created_at`.
- **Business tables** derive `created_at` from the date the record would
  first have existed (`registration_date`, `start_date`, `opened_date`,
  `dispatch_date`, …).
- **Rows with a real second event** get a genuinely later `updated_at` —
  rental returns, subscription cancellations, support-ticket closures,
  deliveries. Those are the rows an incremental load should pick up on a
  later run, so build your pipeline expecting them.
- `updated_at` is never earlier than `created_at`, and neither column is
  ever null.

### Does this affect the data-quality exercise?

No. The planted data-quality issues you are asked to find and handle in
Question 8, Task 2 are all still there, untouched, in their original
columns. The new audit columns are clean on every row and are **not** part
of that exercise.

### What you need to do

1. Delete your existing `abc_hub_operational` database (or drop and
   recreate the schema).
2. Re-run `ddl/operational_schema.sql` from the updated package — the DDL
   now declares the two new columns.
3. Reload all 26 CSVs from the updated `data/` folder.

Loading instructions and the correct table load order are in
[`ABC Hub Data Package/packages/README.md`](ABC%20Hub%20Data%20Package/packages/README.md).

If you have already built NiFi flows against the old schema, they will
still work — the new columns are appended at the end, so nothing you
already mapped has moved.
