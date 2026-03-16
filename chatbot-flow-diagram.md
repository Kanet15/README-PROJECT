# Chatbot Flow Diagram (Slide Ready)

เอกสารนี้ทำสำหรับใส่สไลด์ โดยมี 2 เวอร์ชัน:
- Business Flow (เข้าใจง่าย)
- Technical Flow (เชิงระบบ)

---

## 1) Business Flow (ไทย+อังกฤษ)

### Mermaid
```mermaid
flowchart TD
  A[ผู้ใช้พิมพ์คำถาม\nUser Question] --> B[Frontend Chat UI\nChatContainer]
  B --> C[ส่งคำถามไป Backend\nPOST /chatbot/ask หรือ /chatbot/ask/stream]
  C --> D[วิเคราะห์คำถาม\nIntent + Security Check]

  D --> E{เลือกเส้นทางตอบ\nResponse Path}
  E --> F[Small Talk\nตอบบทสนทนาทั่วไป]
  E --> G[Live Data/API\nข้อมูลสด เช่น ห้องว่าง/ข้อมูลล่าสุด]
  E --> H[Knowledge Base (RAG)\nค้นความรู้ + สร้างคำตอบ]

  F --> I[สร้างคำตอบ\nGenerate Reply]
  G --> I
  H --> I

  I --> J[ส่งคำตอบกลับ UI\nReply + Source + Updated_at]
  J --> K[บันทึกประวัติ\nConversation Log / Analytics]

  L[Fallback\nตอบข้อความสำรองเมื่อผิดพลาด/ไม่ผ่านเงื่อนไข] --> J
  D -. fail/safe .-> L
  H -. validation fail .-> L
```

### Text Flow Outline
1. ผู้ใช้ส่งคำถามในหน้า Chatbot
2. Frontend เรียก API ไป Backend
3. Backend ตรวจความปลอดภัยและวิเคราะห์ intent
4. ระบบเลือกเส้นทางตอบ (Small Talk / Live Data / KB-RAG)
5. ระบบสร้างคำตอบหรือ fallback
6. ส่งคำตอบกลับหน้าจอ พร้อม metadata
7. บันทึก log เพื่อวิเคราะห์คุณภาพ

### Presenter Note (20-30 วินาที)
- “ระบบนี้ไม่ได้ตอบแบบเดียว แต่เลือกเส้นทางตามประเภทคำถาม”
- “มีชั้นความปลอดภัยก่อนตอบ”
- “ถ้าตอบไม่ได้จะมี fallback เพื่อไม่ให้ระบบเงียบหรือพัง”

---

## 2) Technical Flow (ไทย+อังกฤษ)

### Mermaid
```mermaid
flowchart TD
  A[Frontend\nChatContainer] --> B[/chatbot/ask หรือ /chatbot/ask/stream]
  B --> C[chatbot_route.py\nSession Key + Runtime Check]
  C --> D[RAGPipeline.answer()/stream_answer()]

  D --> E[Security Layer\nPromptSanitizer + InjectionDetector + RateLimiter]
  E --> F[Intent Layer\nIntentRouter + LLM Intent Classifier]

  F --> G{Routing Decision}
  G --> H[Small Talk Path]
  G --> I[Live Data Path]
  G --> J[RAG Path]

  J --> J1[QueryRewriteService]
  J1 --> J2[HybridRetriever\nMySQL + Qdrant]
  J2 --> J3[CrossEncoderReranker]
  J3 --> J4[ContextOptimizer]
  J4 --> J5[LLM Generate/Stream]
  J5 --> J6[OutputSafetyValidator + Grounding]

  H --> K[Final Answer]
  I --> K
  J6 --> K

  K --> L{Response Mode}
  L --> M[JSON Reply\nreply/source/updated_at]
  L --> N[SSE Stream\ntokens + meta + done]

  M --> O[Frontend Render]
  N --> O

  K --> P[Logging & Analytics\nstructured trace + conversation log]

  Q[Fallback Engine\nsafe response] --> K
  E -. blocked/suspicious .-> Q
  J6 -. invalid/low groundedness .-> Q
  D -. exception .-> Q
```

### Text Flow Outline
1. Frontend ส่งข้อความไป endpoint chatbot
2. Route layer ตรวจ runtime readiness และสร้าง session key
3. Pipeline ตรวจความปลอดภัย (sanitize, injection, rate limit)
4. Intent layer ตัดสินเส้นทาง
5. ถ้าเป็น RAG จะวิ่ง rewrite -> retrieve -> rerank -> optimize -> generate -> validate
6. รวมคำตอบสุดท้ายและส่งกลับแบบ JSON หรือ SSE
7. บันทึก structured logs + conversation analytics
8. หากมีปัญหา ใช้ fallback response ที่ปลอดภัย

### Presenter Note (30-45 วินาที)
- “จุดแข็งคือมี pipeline ครบตั้งแต่ security ถึง quality validation”
- “RAG path มีทั้ง retrieval, rerank และ grounding เพื่อคุมคุณภาพคำตอบ”
- “รองรับทั้งตอบครั้งเดียวและ stream แบบ token เพื่อ UX ที่ลื่นขึ้น”

---

## 3) Slide Tips (ใช้งานจริง)

1. ใช้ Business Flow ในสไลด์แรกของ chatbot
2. ใช้ Technical Flow ในสไลด์ถัดไปสำหรับกรรมการสายเทคนิค
3. ไฮไลต์ 3 กล่องสำคัญด้วยสี: Security, RAG, Fallback
4. ใส่คำสั้นใต้รูป: “Secure -> Route -> Retrieve -> Validate -> Respond”
