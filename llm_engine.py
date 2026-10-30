from __future__ import annotations
import re
import ollama

MODEL_NAME = "qwen2.5-coder:7b"

# 1. System Prompt for SQL Generation
SQL_SYSTEM_PROMPT = """You are a MySQL database expert for a Building Electrical Telemetry system.
Given a database schema and a user question, write ONE valid MySQL SELECT query that answers the question.

RULES FOR COLUMN NAMES & SCHEMAS:
1. ONLY use column names that appear strictly in the provided SCHEMA text.
2. If ordering by time, inspect the schema:
   - Use `vidatetime` if `vicreatedtime` is not present in the schema.
3. NEVER assume generic column names like 'date', 'time', or 'created_at' unless they exist in the schema.
4. For `vinereadings`:
   - Voltages: virv, viyv, vibv, vinv
   - Currents: viri, viyi, vibi
   - Telemetry: vicurrentimbalance, vibattery, vitemp, vienergy, vidatetime

RULES:
- Return ONLY executable raw SQL starting with SELECT or WITH.
- Do NOT output markdown code fences (no ```sql).
- Never write INSERT, UPDATE, DELETE, DROP, ALTER, or TRUNCATE statements.
- If conversation context is provided and the user asks a follow-up (e.g., "filter only those", "now show only", "where voltage was below 220"), build upon the previous query.
"""

# 2. System Prompt for Final Natural Language Summaries
ANSWER_SYSTEM_PROMPT = """You are a helpful data analyst. Given a user's question, the SQL
query that was run, and the query result, write a short, clear natural-language answer.
Do not mention SQL syntax. Just answer the question using the data given.
"""


class LLMEngine:
    def __init__(self, model_name: str = MODEL_NAME, host: str = "http://localhost:11434"):
        self.model_name = model_name
        self.client = ollama.Client(host=host)

    def load(self) -> LLMEngine:
        """
        Confirms Ollama server reachability and checks if the model is downloaded.
        """
        try:
            models = self.client.list()
            names = [m.get("model", m.get("name", "")) for m in models.get("models", [])]
        except Exception as e:
            raise RuntimeError(
                "Could not reach Ollama server at http://localhost:11434. "
                "Is Ollama installed and running? Try running: `ollama serve`"
            ) from e

        if not any(self.model_name in n for n in names):
            raise RuntimeError(
                f"Model '{self.model_name}' not found in Ollama. "
                f"Run: `ollama pull {self.model_name}` first. "
                f"Models currently available: {names}"
            )
        return self

    def _chat(self, system_prompt: str, user_prompt: str, max_tokens: int = 400) -> str:
        response = self.client.chat(
            model=self.model_name,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            options={
                "temperature": 0.1,
                "num_predict": max_tokens,
            },
        )
        return response["message"]["content"].strip()

    def generate_sql(self, question: str, schema_text: str, history: list[dict] | None = None) -> str:
        context_block = ""
        if history:
            recent_turns = []
            for h in history[-4:]:
                if h.get("role") == "user":
                    recent_turns.append(f"User: {h.get('content', '')}")
                elif h.get("role") == "assistant" and h.get("sql"):
                    recent_turns.append(f"Previous SQL: {h.get('sql', '')}")
            if recent_turns:
                context_block = "PREVIOUS CONVERSATION CONTEXT:\n" + "\n".join(recent_turns) + "\n\n"

        user_prompt = f"SCHEMA:\n{schema_text}\n\n{context_block}CURRENT QUESTION:\n{question}\n\nSQL:"
        raw_sql = self._chat(SQL_SYSTEM_PROMPT, user_prompt, max_tokens=300)

        clean_sql = re.sub(r"^```(?:sql)?\s*", "", raw_sql, flags=re.IGNORECASE)
        clean_sql = re.sub(r"\s*```$", "", clean_sql).strip()
        return clean_sql.strip("`")

    def generate_answer(self, question: str, sql: str, result_preview: str) -> str:
        user_prompt = (
            f"QUESTION:\n{question}\n\nSQL RUN:\n{sql}\n\nRESULT:\n{result_preview}\n\nANSWER:"
        )
        return self._chat(ANSWER_SYSTEM_PROMPT, user_prompt, max_tokens=250)


def enable_offline_mode():
    pass