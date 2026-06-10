# 🧠 Neuro-AI Parallels Database

> *What if the most advanced AI architecture already exists — inside the human brain?*

An Oracle SQL database that maps structural, functional, and computational parallels between biological brain structures and artificial neural network components. Built as a research tool for identifying where neuroscience knowledge is mature enough to directly inform AI design.

---

## The Thesis

The dominant direction in neuro-AI research is unidirectional: use AI to serve neuroscience — brain imaging, drug discovery, diagnostic tools.

This project explores the opposite direction.

The human brain is the most energy-efficient, adaptive, generalized intelligence system known. Decades of neuroscience research describe precisely how it is built — its structures, mechanisms, and functional organization. The argument behind this database is that **this biological knowledge should be feeding back into AI architecture design**, not just being analyzed by AI.

The database answers one precise question:

> *Where are the biological solutions mature enough, and the artificial equivalents weak enough, that the brain could serve as a design template for next-generation AI?*

---

## Database Overview

| Entity | Count |
|---|---|
| Research Papers | 57 real published papers |
| Documented Parallels | 20 |
| Biological Structures | 16 |
| Artificial Structures | 15 |
| Authors | 20 |
| Institutions | 15 |
| Funding Sources | 8 |
| Tables | 14 |

---

## The 6 Functional Categories

Every parallel in the database belongs to one or more of these categories, organizing the neuro-AI intersection by cognitive and computational function:

| Category | Biological Side | Artificial Side |
|---|---|---|
| **Perception & Encoding** | Visual cortex hierarchy (V1→IT) | Convolutional Neural Networks |
| **Attention & Selectivity** | Prefrontal & parietal cortex | Transformer attention heads |
| **Memory & Storage** | Hippocampus, sleep replay | LSTM, continual learning with replay |
| **Learning & Adaptation** | Synaptic plasticity (STDP), Hebbian learning | Backpropagation, plastic weights |
| **Decision & Prediction** | Dopaminergic system, predictive coding | TD learning, variational autoencoders |
| **Output & Generation** | Primary motor cortex | Sequence-to-sequence RNNs |

---

## Schema Design

14 tables, fully normalized to 3NF.

```
FUNCTIONAL_CATEGORY
       │
       ├──< BIO_STRUCTURE_CATEGORY >── BIOLOGICAL_STRUCTURE
       ├──< ART_STRUCTURE_CATEGORY >── ARTIFICIAL_STRUCTURE
       │
       └──────────────── PARALLEL ────────────────────────────┐
                              │                               │
                       PAPER_PARALLEL                         │
                              │                               │
                           PAPER ──< PAPER_AUTHOR >── AUTHOR ─┘
                              │          │                │
                       PAPER_FUNDING  (position,      AUTHOR_INSTITUTION
                              │       corresponding)       │
                       FUNDING_SOURCE                  INSTITUTION
```

**Design decisions worth noting:**

- `PARALLEL` is the central entity — every paper, biological structure, and artificial structure connects through it
- `parallel_type` is constrained to `Structural / Functional / Computational` — a deliberate taxonomy that distinguishes same-architecture parallels from same-role or same-math parallels
- `confidence_level` on `PARALLEL` reflects evidence quality, not editorial opinion
- `potential_bias` on `FUNDING_SOURCE` makes funding analysis a first-class feature, not an afterthought
- Junction tables (`PAPER_PARALLEL`, `PAPER_AUTHOR`, etc.) use composite primary keys — no surrogate IDs where not needed
- All INSERTs use subquery-based FK lookups rather than hardcoded IDs, making the script portable across re-runs

---

## Key Parallels

A selection of the most precisely established parallels in the database:

**Dopamine → Temporal Difference Learning** *(Computational, High confidence)*
Dopamine neurons fire exactly as the TD error signal predicts: phasic activation for unexpected reward, silence for predicted reward, pause for omitted reward. The mathematical identity between the dopamine signal and the TD error term is among the most precisely quantified parallels between neuroscience and AI. — *Schultz, Dayan & Montague (1997)*

**V1 Simple Cells → Convolutional Filters** *(Structural, High confidence)*
CNNs trained on object recognition independently converge on oriented edge detectors identical to V1 simple cell receptive fields. The structural identity was discovered empirically, not by design. — *Yamins et al. (2014), Olshausen & Field (1996)*

**Sleep Replay → Continual Learning with Replay** *(Functional, High confidence)*
Biological sleep consolidates memories from hippocampus to neocortex through compressed generative replay. Continual learning algorithms implement the same computational principle to prevent catastrophic forgetting. The design insight: AI replay should be generative and compressed, not raw stored samples. — *Tadros et al. (2022)*

**Synaptic Plasticity (STDP) → Backpropagation** *(Computational, High confidence)*
STDP achieves weight updates through local spike-timing signals. Backpropagation requires a global error signal that is biologically implausible (the weight transport problem). Both achieve comparable learning outcomes. The open problem this parallel identifies: designing local learning rules that approximate backpropagation without global error propagation. — *Schiess et al. (2016), Miconi et al. (2018)*

---

## SQL Concepts Demonstrated

This project covers the full Oracle SQL curriculum:

**DDL (Data Definition Language)**
- `CREATE TABLE` with PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, DEFAULT constraints
- `ALTER TABLE` — ADD column, MODIFY column, ADD constraint, DROP column
- `DROP TABLE` — full table lifecycle demonstration

**DML (Data Manipulation Language)**
- `INSERT` — 370+ rows across 14 tables using subquery-based FK lookups
- `UPDATE` — correcting data quality issues with real justification
- `DELETE` — removing unverified data links with pre/post verification

**SELECT Queries**
- Comparison operators: `=`, `>`, `<`, `BETWEEN`, `IN`, `LIKE`, `IS NULL`
- Group functions: `COUNT`, `AVG`, `MAX`, `MIN`, `SUM` with `GROUP BY` and `HAVING`
- Single-row functions: `ROUND`, `TRUNC`, `UPPER`, `SUBSTR`, `LENGTH`, `CONCAT`, `MONTHS_BETWEEN`, `EXTRACT`
- Conditional expressions: `CASE`, `DECODE`, `NVL`, `NVL2`, `COALESCE`
- Joins: INNER JOIN (2–5 tables), LEFT OUTER JOIN
- Subqueries: single-row, multi-row (`IN`, `NOT IN`, `ANY`), correlated, inline view
- Set operators: `UNION`, `UNION ALL`, `INTERSECT`, `MINUS`

**Views**
- `ACTIONABLE_PARALLELS` — surfaces parallels ready to inform AI design
- `RESEARCHER_PROFILE` — author impact and institutional affiliation overview
- `FUNDING_BIAS_REPORT` — bias risk assessment per parallel based on funder type
- `CREATE OR REPLACE VIEW` and `DROP VIEW` demonstrated

---

## The Three Views

### `ACTIONABLE_PARALLELS`
The intellectual conclusion of the database. For each parallel, surfaces: number of supporting papers, methodology diversity, industry funding count, and a design insight preview. Filters for High and Medium confidence parallels only.

```sql
SELECT category_name, parallel_name, parallel_type,
       supporting_papers, methodology_diversity,
       industry_funded_papers, insight_preview
FROM actionable_parallels
WHERE supporting_papers >= 4
ORDER BY supporting_papers DESC;
```

### `FUNDING_BIAS_REPORT`
For every parallel, counts how many supporting papers come from industry, government, and non-profit sources, and assigns a bias risk label. Addresses the core critical question: *can we trust this parallel, or is the evidence commercially biased?*

### `RESEARCHER_PROFILE`
Every author in the database with their institution type, primary domain (Neuroscience / AI / Both), h-index, and contribution count. Enables filtering by whether the researchers who established a parallel come from academia or industry.

---

## Sample Papers in the Database

The database contains 57 real published papers. A selection:

- Schultz, Dayan & Montague (1997) — *A Neural Substrate of Prediction and Reward* — Science
- Olshausen & Field (1996) — *Emergence of simple-cell receptive field properties by learning a sparse code* — Nature
- Yamins & DiCarlo (2016) — *Using goal-driven deep learning models to understand sensory cortex* — Nature Neuroscience
- Richards et al. (2019) — *A deep learning framework for neuroscience* — Nature Neuroscience
- Hassabis et al. (2017) — *Neuroscience-inspired artificial intelligence* — Neuron
- Zador et al. (2023) — *Catalyzing next-generation artificial intelligence through NeuroAI* — Nature Communications
- Tadros et al. (2022) — *Sleep-like unsupervised replay reduces catastrophic forgetting* — Nature Communications
- Miconi, Clune & Stanley (2018) — *Differentiable plasticity* — ICML

---

## Repository Structure

```
neuro-ai-parallels-db/
│
├── README.md
│
├── sql/
│   ├── 01_create_tables.sql       # DDL: all 14 tables with constraints
│   ├── 02_alter_drop.sql          # DDL: ALTER TABLE and DROP TABLE examples
│   ├── 03_insert_data.sql         # DML: full dataset insertion
│   ├── 03b_insert_continuation.sql
│   ├── 04_update_delete.sql       # DML: UPDATE and DELETE examples
│   ├── 05_select_queries.sql      # SELECT: all 36 queries across 7 categories
│   └── 06_views.sql               # Views: creation, update, drop
│
└── docs/
    └── NeuroAI_Database_Project.docx   # Full submission document
```

---

## Future Vision

This database is designed as the foundation for a deployed interactive research tool.

**Phase 1 (current):** Oracle SQL schema with full dataset — research-grade structured knowledge base.

**Phase 2:** Export to PostgreSQL + build a REST API (Node.js or FastAPI) exposing the parallel map, paper evidence, and bias analysis endpoints.

**Phase 3:** Deploy as a searchable web interface — researchers can query: *"show me all High confidence Structural parallels in the Attention category with no industry-funded papers"* — and receive the result in seconds.

**Phase 4:** Community contribution layer — allow researchers to submit new parallels with paper citations, reviewed before database inclusion. The goal is a living, peer-reviewed map of the neuro-AI intersection.

The long-term vision: a public resource that makes the biological blueprints for AI design accessible, searchable, and critically annotated for funding bias — so the next generation of AI architecture can be built on neuroscience, not just inspired by it.

---

## Technical Details

- **Database:** Oracle SQL (tested on Oracle LiveSQL / FreeSQL 23ai)
- **Tables:** 14
- **Constraints:** 14 PRIMARY KEY, 18 FOREIGN KEY, 9 UNIQUE, 13 CHECK, 4 DEFAULT
- **Total rows:** ~370 across all tables
- **All foreign key inserts** use subquery-based name lookups for portability

---

## Author

**Aya-Dilara**
Informatics, Year II — UTM Bucharest

*Interests: neuro-AI intersection, database architecture, systems thinking across medicine and technology*

---

*Built as an academic database project. All 57 papers are real published research. All authors, institutions, and DOIs are real.*
