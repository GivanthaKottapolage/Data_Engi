# Catch-up Session — Apache NiFi

A catch-up session on **data ingestion with Apache NiFi**. Twelve flows build up from core routing to enterprise-grade ingestion — import each one into NiFi, run it, and study how the processors are wired.

## The 12 flows

All flow definitions live in [`nifi_student_curriculum/`](nifi_student_curriculum/).

| # | Flow | Focus |
|---|------|-------|
| 01 | Core Routing (Hello World) | Processors, connections, routing |
| 02 | File System Ingestion | ListFile / FetchFile |
| 03 | Attributes vs Content | FlowFile attributes vs body |
| 04 | Record Revolution (JSON → CSV) | Record readers/writers |
| 05 | HTTP / API Integration | InvokeHTTP |
| 06 | Error Handling & Retries | Failure relationships, retry loops |
| 07 | Split & Merge Records | SplitRecord / MergeRecord |
| 08 | Database Ingestion | PutDatabaseRecord |
| 09 | Data Enrichment (Lookup) | LookupRecord / lookup services |
| 10 | State Management (Incremental) | Processor state, incremental loads |
| 11 | Custom Scripting | ExecuteScript |
| 12 | Enterprise Performance Tuning | Concurrency, back pressure, batching |

## How to use

1. In the NiFi canvas, drag on a **Process Group** and choose **Import from file** (or upload the flow definition), then pick a `Flow_XX_*.json`.
2. Most flows run immediately — sample data is embedded inline in the `GenerateFlowFile` processors.
3. Some flows read local files (Flow 02, 08, 09, 10). See [`nifi_student_curriculum/datasets/README.txt`](nifi_student_curriculum/datasets/README.txt) for where to copy the `datasets/` files.

Work through them in order — each flow builds on the previous one.

---

*Zuu Crew — Machine Learning Academy*
