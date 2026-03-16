/*
  Example Snowflake Agent Model using SQL content as specification
  This demonstrates how to use the YAML specification directly as the model's SQL content.

  For more information on Snowflake Agents, see:
  https://docs.snowflake.com/en/sql-reference/sql/create-agent
*/

{{
    config(
        materialized='agent',
        comment='A business assistant agent with YAML as SQL content',
        profile='{"display_name": "SQL Content Agent", "avatar": "business-icon.png", "color": "purple"}'
    )
}}

models:
  orchestration: claude-4-sonnet

orchestration:
  budget:
    seconds: 30
    tokens: 16000

instructions:
  response: "You will respond in a friendly but concise manner"
  orchestration: "For any revenue question use Analyst; for policy use Search"
  system: "You are a friendly agent that helps with business questions"
  sample_questions:
    - question: "What was our revenue last quarter?"
      answer: "I'll analyze the revenue data using our financial database."
    - question: "What is our company policy on remote work?"
      answer: "Let me search our policy documentation for that information."

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "Analyst1"
      description: "Converts natural language to SQL queries for financial analysis"
  - tool_spec:
      type: "cortex_search"
      name: "Search1"
      description: "Searches company policy and documentation"

tool_resources:
  Analyst1:
    semantic_view: "{{ var('semantic_view_name', 'default.schema.semantic_view') }}"
  Search1:
    name: "{{ var('search_service_name', 'default.schema.search_service') }}"
    max_results: "5"
    filter:
      "@eq":
        region: "North America"
    title_column: "title"
    id_column: "id"