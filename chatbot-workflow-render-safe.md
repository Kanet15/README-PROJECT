# Chatbot Workflow (Render-Safe)

ไฟล์นี้ตั้งใจทำมาเพื่อแก้ปัญหา `Unable to render rich display`
โดยใช้ข้อความล้วน (ASCII) ไม่มี Mermaid

## End-to-End Workflow

```text
User Question (Frontend: ChatContainer)
      │
      ▼
POST /chatbot/ask  หรือ  POST /chatbot/ask/stream
      │
      ▼
chatbot_route.py
  - ตรวจ Chatbot runtime readiness
  - สร้าง session key (user/token/ip)
      │
      ▼
RAGPipeline.answer() / stream_answer()
      │
      ▼
Security Gate
  - PromptSanitizer
  - PromptInjectionDetector
  - SecurityRateLimiter
      │
      ▼
Intent Decision
  - IntentRouter (rule-based)
  - LLM Intent Classifier (optional by config)
      │
      ▼
Routing Decision
 ┌────────────────────┬──────────────────────┬─────────────────────────────┐
 │                    │                      │                             │
 ▼                    ▼                      ▼                             │
Small Talk Path     Live Data Path         Knowledge/RAG Path             │
  - quick reply       - live availability    - Query Rewrite               │
                     - contact/utility data  - Hybrid Retrieval            │
                                             (MySQL + Qdrant + Embedding)  │
                                            - CrossEncoder Reranker        │
                                            - Context Optimizer            │
                                            - LLM Generate/Stream          │
                                            - Output Validation + Grounding│
 └────────────────────┴──────────────────────┴─────────────────────────────┘
                      │
                      ▼
Fallback Handling (เมื่อ blocked / invalid / exception)
                      │
                      ▼
Final Response
  - /ask: JSON { reply, source, updated_at }
  - /ask/stream: SSE token + meta + done
                      │
                      ▼
Frontend Render
                      │
                      ▼
Logging & Analytics
  - structured trace log
  - conversation log (DB)
  - analytics endpoints
```

## Models & Platform

- LLM Platform: KKU Intel (GenAI KKU)
  - Base URL: https://gen.ai.kku.ac.th/api/v1
- Primary LLM: gpt-5.1
- Embedding: BAAI/bge-m3
- Reranker: BAAI/bge-reranker-large
