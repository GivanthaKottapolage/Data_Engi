# Airflow 3.x Data Engineering — 15 DAG Examples

A progressive practical set mapping Data Engineering theory to Apache Airflow 3.x mechanisms.

## DAGs
01 basic ETL — BashOperator
02 Python TaskFlow — @task
03 SQL warehouse — SQLExecuteQueryOperator
04 API ingestion — HttpOperator
05 FileSensor — file arrival
06 PythonSensor — business condition
07 ExternalTaskSensor — cross-DAG dependency
08 Branching — @task.branch
09 Dynamic Task Mapping — expand()
10 Task Groups — @task_group
11 KubernetesPodOperator — containerized workload
12 Assets — event/data-aware scheduling
13 TriggerDagRunOperator — DAG-to-DAG triggering
14 Deferrable sensor — triggerer / resource-efficient waiting
15 Capstone — combined modern data platform pattern

## Notes
- Examples use the Airflow 3 public Task SDK (`airflow.sdk`) where appropriate.
- Provider imports are intentionally explicit because Airflow integrations live in provider packages.
- Examples that require external infrastructure are safe demonstration DAGs; configure connections, paths, Kubernetes, or cloud resources before running them.
- Airflow's current stable docs are 3.3.x as of August 2026; this package focuses on Airflow 3.x concepts and highlights Airflow 3-era APIs.

## AI / LLM DAGs (16–20)

16. LLMOperator — general generation/summarization
17. Structured extraction — Pydantic model output
18. LLM classification + dynamic mapping pattern
19. AgentOperator — tool-using AI agent / SQL analysis
20. AI data platform capstone — ingestion + asset + AI enrichment pattern

### Current AI provider note
Airflow now has a dedicated `apache-airflow-providers-common-ai` provider for LLM and agent workflows, requiring Airflow 3.0+. It supports vendor-neutral model connections, LLMOperator, AgentOperator, document/retrieval patterns, and human approval capabilities. The OpenAI provider separately exposes OpenAI-specific Responses, embeddings, and Batch operators. These are provider features, not Airflow core itself.

The examples use the provider APIs documented for the current 2026 provider releases. Because the common-ai provider is still a 0.x series, pin and test the exact provider version used by your course environment before production use.
