# SabiSnap ADK Multi-Agent Engine

> **Participant:** Google for Startups Immersion EMEA 2026 (Powered by Antler)  
> **Founder & Technical Lead:** Emmanuel Gbenga Akande (SabiSnap Ltd, RC 9414613)  
> **Development Environment:** Google Antigravity & Google Agent Development Kit (ADK)  
> **Deployment Target:** Google Cloud Run (Serverless AI)

---

## 1. Executive Summary & Problem Space

In Nigeria and across Sub-Saharan Africa, **over 105,000 public and low-fee private primary schools operate with zero internet connectivity**. Extreme device poverty prevents 1-to-1 student tablet hardware models from ever achieving economic sustainability.

**SabiSnap delivers a 1-to-Many Offline Classroom Learning Engine:**
* **1 Teacher Smartphone + 1 Low-Cost Mini-Projector = An entire classroom of 40 students learning visually.**
* Teachers snap physical textbook pages or handwritten syllabus notes.
* The SabiSnap Engine matches the Nigerian National Curriculum (NERDC) and synthesizes culturally grounded, 3D animated visual lessons featuring **"Baba Tutor"** (powered by Google LearnLM).
* Lesson bundles are serialized into self-contained `.sabisnap.json` artifacts, cached on the teacher's phone, and projected **100% offline in Airplane Mode**.

### Hardware Unit Economics (The Pass-Through Trojan Horse)
* **Mini-Projector Unit Cost:** **$30 USD wholesale**.
* **Zero Markup Pass-Through:** SabiSnap supplies mini-projectors to schools **at cost with 0.0% profit markup** as a hardware enabler.
* **Recurring Software ARR:** Eliminating hardware friction unlocks the core recurring **$50 USD / classroom / term software subscription ($150 ARR per classroom)**.
* **Validated Kaduna Pilot Proof:** Deployed across 3 schools in Kaduna (*Gracious Kids Academy*, *Precious Kids School*, *Beulah Schools*) using 3 founder-funded projectors ($90 total COGS), generating $150 in verified upfront cash receipts ($50 per pilot school, $60 net operating cash, zero corporate debt).

---

## 2. Multi-Agent Architecture (Google ADK)

The engine is built on the **Google Agent Development Kit (`google-adk`)** using a **Hierarchical Agent Tree** pattern:

```mermaid
graph TD
    Teacher[Teacher Input: Textbook Snap / Handwritten Note] --> Router[TeacherAssistantRouter (Root Agent)]
    Router -->|Curriculum Alignment Routing| Matcher[CurriculumMatcherAgent (NERDC Tool)]
    Matcher -->|Validated Syllabus Objective & Grade| Director[BabaTutorDirectorAgent (Google LearnLM)]
    Director --> Serializer[Offline Edge Serialization: .sabisnap.json]
    Serializer --> OfflinePlay[Classroom Mini-Projector: 100% Offline 1-to-Many Playback]
```

### Specialized Agents

#### 1. `TeacherAssistantRouter` (Root Agent)
* **Role:** Intake and intent classification.
* **Function:** Ingests raw OCR text from textbook snapshots, extracts grade level and subject, and routes the context to specialized sub-agents based on agent descriptions.
* **State Management:** Manages the ADK session state dictionary and orchestrates peer transfers.

#### 2. `CurriculumMatcherAgent`
* **Role:** Nigerian National Educational Research and Development Council (NERDC) syllabus alignment.
* **Tools:** Integrates `nerdc_curriculum_lookup` tool to map textbook topics against official national grade benchmarks (e.g., Primary 4 Science, Primary 5 Mathematics).
* **Output:** Validates approved curriculum themes, performance objectives, and key local concepts.

#### 3. `BabaTutorDirectorAgent`
* **Model:** Google LearnLM / Gemini 2.5.
* **Role:** Pedagogical animation director.
* **Pedagogical Persona:** **"Baba Tutor"** — a relatable West African mentor persona employing local analogies (e.g., explaining photosynthesis through solar plantain chips or fractions using market oranges).
* **Classroom Engagement Scaffolding:** Generates 3-part pedagogical scripts with explicit call-and-response questions for whole-classroom participation.
* **Edge Serialization:** Emits complete `.sabisnap.json` lesson bundles containing narrative beats, 3D asset cues, quiz prompts, and audio timestamps.

---

## 3. Serverless Cloud Run Deployment & Concurrency Governance

*(Architectural Alignment: Immersion Session 3 with Zack Akil, Google Cloud)*

The engine is fully containerized and configured for automated CI/CD deployment to Google Cloud Run with strict concurrency governance to handle burst loads without quota throttling:

* **Container:** [`Dockerfile`](Dockerfile) based on `python:3.11-slim`.
* **CI/CD:** [`cloudbuild.yaml`](cloudbuild.yaml) automating build, push to Google Artifact Registry, and deployment to Cloud Run.
* **Concurrency Governance (`--concurrency=1`, `--max-instances=5`):** Each container instance handles exactly one heavy multimodal document at a time, while maximum instances are bounded to prevent upstream Gemini API rate-limit throttling (HTTP 429) during burst school onboarding.
* **Lossless Event Buffering:** Ingestion events from Google Cloud Storage trigger through an Eventarc / Pub/Sub messaging queue. Scans are buffered in the queue rather than dropped, allowing Cloud Run workers to pull at a governed rate.
* **Deterministic vs. Probabilistic Division:** Following Google Cloud's core tenet (*"Code for math, Gemini for document reading"*), deterministic Python hashing handles curriculum code matching and offline checksums, while Gemini handles multimodal visual reasoning.
* **Scale-to-Zero:** Serverless architecture ensuring zero idle compute costs.
* **Observability:** Integrated with Google Cloud Trace and Cloud Logging via OpenTelemetry (`google-adk[otel-gcp]`).

---

## 4. Asynchronous Curriculum Compilation (Gemini Batch API)

For nationwide school onboarding, real-time sub-second inference is neither required nor cost-optimal. SabiSnap incorporates the **Google Gemini Batch API** ([`sabisnap_batch_compiler.py`](sabisnap_batch_compiler.py)):

* **50% Token Cost Discount:** Entire 12-week national term syllabi are submitted via JSONL batch manifests, slashing API compute expenses by half.
* **Zero Rate Limit Pressure:** Batch workloads run asynchronously within Google Cloud without consuming real-time Requests Per Minute (RPM) quotas.
* **Overnight Edge Cache Sync:** Pre-compiled `.sabisnap.json` lesson bundles are stored directly in Cloud Storage for one-touch offline caching on teacher smartphones before term resumption.

---

## 5. Repository Structure

```
sabisnap_adk_engine/
├── sabisnap_adk_pipeline.py   # Complete ADK multi-agent pipeline implementation
├── sabisnap_batch_compiler.py # Gemini Batch API asynchronous curriculum compiler
├── deploy_cloud_run.sh        # Bash deployment script with concurrency governance
├── Dockerfile                 # Cloud Run container definition
├── cloudbuild.yaml            # Google Cloud Build automated CI/CD pipeline
├── requirements.txt           # Python dependencies (google-adk, google-genai, etc.)
├── offline_cache/             # Sample serialized edge lesson bundles (.sabisnap.json)
│   ├── SABISNAP-LES-49DA2F7F.sabisnap.json  # Primary 4 Science: Photosynthesis
│   └── SABISNAP-LES-CE7D374C.sabisnap.json  # Primary 5 Math: Fractions
└── README.md                  # Institutional architectural documentation
```

---

## 5. Quickstart & Local Execution

### Prerequisites
* Python 3.10+
* Google Cloud project with Vertex AI / Gemini API enabled

### Setup
```bash
# Clone the repository
git clone https://github.com/EG-AKANDE/sabisnap-adk-engine.git
cd sabisnap-adk-engine

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env  # Add GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION, MODEL=gemini-2.5-flash
```

### Run the ADK Multi-Agent Test Suite
```bash
python sabisnap_adk_pipeline.py
```

The test runner will execute sample textbook snapshots for Primary 4 Science and Primary 5 Math, outputting validated `.sabisnap.json` lesson bundles into `offline_cache/`.

---

## 6. Immersion EMEA 2026 Cohort Alignment
* **Session 1 (Oct 22):** Developed with Google Antigravity.
* **Session 2 (Oct 23):** Built with Google Agent Development Kit (ADK) multi-agent hierarchical tree.
* **Session 3 (Oct 27):** Cloud Run serverless deployment ready for Zack Akil's Serverless AI session.
