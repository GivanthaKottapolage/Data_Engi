# Airflow 3.x AI / LLM Theory Map

Airflow is the orchestrator; the model/provider performs AI work.

| Requirement | Airflow mechanism |
|---|---|
| Prompt-based generation | LLMOperator |
| Structured extraction | LLMOperator + Pydantic BaseModel |
| Classification | LLMOperator / @task.llm |
| Tool-using AI agent | AgentOperator / @task.agent |
| Human approval | LLM approval options |
| OpenAI native Responses API | OpenAIResponseOperator |
| Embeddings | OpenAIEmbeddingOperator |
| Async bulk AI jobs | OpenAITriggerBatchOperator |
| AI + data arrival | Assets |
| Many records | Dynamic Task Mapping |
| SQL analysis | Agent toolset / SQL-capable agent |
| Local/self-hosted models | OpenAI-compatible model server + common-ai |

Key distinction:
- `apache-airflow-providers-common-ai` is the vendor-neutral AI/agent layer.
- `apache-airflow-providers-openai` is for OpenAI-specific APIs and features.
- Airflow itself remains the orchestrator.
