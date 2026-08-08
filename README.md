# Neuro-AI Parallels Database
> An Oracle SQL database mapping structural, functional, and computational parallels between biological brain structures and artificial neural-network components — built to identify where neuroscience is mature enough to directly inform AI design.

**Stack:** Oracle SQL (23ai) · 14-table 3NF schema · **Status:** Research-grade knowledge base

## Problem

Most neuro-AI research runs in one direction: AI serving neuroscience — imaging, drug discovery, diagnostics. This project explores the reverse.

The human brain is the most energy-efficient, adaptive, general intelligence system known, and decades of neuroscience describe precisely how it is built. The argument behind this database is that biological knowledge should feed *back* into AI architecture design, not only be analysed by AI.

The database answers one precise question:
> Where are the biological solutions mature enough, and the artificial equivalents weak enough, that the brain could serve as a design template for next-generation AI?

## Overview

A normalized relational knowledge base linking documented brain-to-AI parallels to the real published papers that establish them, the researchers and institutions behind them, and the funding sources that may bias them.

| Entity | Count |
| --- | --- |
| Research papers (real, published) | 57 |
| Documented parallels | 20 |
| Biological structures | 16 |
| Artificial structures | 15 |
| Authors | 20 |
| Institutions | 15 |
| Funding sources | 8 |
| Tables | 14 |

Every parallel is organized under six functional categories spanning the cognitive-computational stack.

| Category | Biological side | Artificial side |
| --- | --- | --- |
| Perception & Encoding | Visual cortex hierarchy (V1→IT) | Convolutional neural networks |
| Attention & Selectivity | Prefrontal & parietal cortex | Transformer attention heads |
| Memory & Storage | Hippocampus, sleep replay | LSTM, continual learning with replay |
| Learning & Adaptation | Synaptic plasticity (STDP), Hebbian | Backpropagation, plastic weights |
| Decision & Prediction | Dopaminergic system, predictive coding | TD learning, variational autoencoders |
| Output & Generation | Primary motor cortex | Sequence-to-sequence RNNs |

## Method

14 tables, normalized to 3NF, with `PARALLEL` as the central entity through which every paper, biological structure, and artificial structure connects.

```
FUNCTIONAL_CATEGORY
       ├──< BIO_STRUCTURE_CATEGORY >── BIOLOGICAL_STRUCTURE
       ├──< ART_STRUCTURE_CATEGORY >── ARTIFICIAL_STRUCTURE
       └──────── PARALLEL ────────┐
                     │            │
              PAPER_PARALLEL      │
                     │            │
                  PAPER ──< PAPER_AUTHOR >── AUTHOR
                     │                         │
              PAPER_FUNDING            AUTHOR_INSTITUTION
                     │                         │
              FUNDING_SOURCE             INSTITUTION
```

Design decisions:
- `parallel_type` is constrained to `Structural / Functional / Computational` — a deliberate taxonomy separating same-architecture parallels from same-role and same-math ones.
- `confidence_level` on `PARALLEL` reflects evidence quality, not editorial opinion.
- `potential_bias` on `FUNDING_SOURCE` makes funding analysis a first-class feature, not an afterthought.
- Junction tables use composite primary keys — no surrogate IDs where they are not needed.
- All inserts resolve foreign keys via subquery name lookups rather than hardcoded IDs, keeping the script portable across re-runs.

Schema surface: 14 primary keys, 18 foreign keys, 9 unique and 13 check constraints, ~370 rows. The SELECT layer exercises multi-table joins, correlated and inline-view subqueries, group functions with `HAVING`, set operators, and conditional expressions.

## Results

Three views carry the analytical conclusions.

- **`ACTIONABLE_PARALLELS`** — for each parallel: supporting-paper count, methodology diversity, industry-funding count, and a design-insight preview. Filtered to High and Medium confidence. This is the intellectual endpoint of the database.
- **`FUNDING_BIAS_REPORT`** — per parallel, counts supporting papers by industry / government / non-profit source and assigns a bias-risk label. Answers: can this parallel be trusted, or is the evidence commercially biased?
- **`RESEARCHER_PROFILE`** — every author with institution type, primary domain (Neuroscience / AI / Both), h-index, and contribution count.

A selection of the most precisely established parallels:

- **Dopamine → Temporal Difference Learning** *(Computational, High)* — dopamine neurons fire as the TD error term predicts: phasic activation for unexpected reward, silence for predicted, pause for omitted. Among the most precisely quantified neuro-AI parallels. *Schultz, Dayan & Montague (1997)*
- **V1 Simple Cells → Convolutional Filters** *(Structural, High)* — CNNs trained on object recognition converge on oriented edge detectors identical to V1 receptive fields, discovered empirically rather than by design. *Yamins et al. (2014); Olshausen & Field (1996)*
- **Sleep Replay → Continual Learning with Replay** *(Functional, High)* — biological consolidation via compressed generative replay; the design insight is that AI replay should be generative and compressed, not raw stored samples. *Tadros et al. (2022)*
- **Synaptic Plasticity (STDP) → Backpropagation** *(Computational, High)* — STDP updates weights via local spike timing; backprop needs a biologically implausible global error signal. The open problem: local rules that approximate backprop without global error propagation. *Schiess et al. (2016); Miconi et al. (2018)*

## Reproduce

```bash
git clone https://github.com/ayadilara10/NeuroAIParallels.git
cd NeuroAIParallels/sql
```
Run against Oracle (tested on LiveSQL / FreeSQL 23ai), in order:

```
01_create_tables.sql        # DDL — 14 tables with constraints
02_alter_drop.sql           # DDL — ALTER / DROP examples
03_insert_data.sql          # DML — full dataset
03b_insert_continuation.sql
04_update_delete.sql        # DML — UPDATE / DELETE with verification
05_select_queries.sql       # 36 queries across 7 categories
06_views.sql                # the three analytical views
```
Expected output: a populated 14-table schema; `SELECT * FROM actionable_parallels` returns High/Medium-confidence parallels ranked by supporting-paper count.

## Roadmap

Each phase states the outcome it unlocks.

**Now — A research-grade structured knowledge base exists.** Parallels, evidence, and funding bias are queryable in SQL.

**Next — Researchers query it without writing SQL.** The knowledge base is usable by its actual audience.
- Export to PostgreSQL and expose a REST API (parallel map, paper evidence, bias analysis).
- Searchable web interface: e.g. "High-confidence Structural parallels in Attention with no industry-funded papers."

**Later — The map stays current without a single maintainer.** The resource is living, not a snapshot.
- Community contribution layer: researchers submit new parallels with citations, reviewed before inclusion — a peer-reviewed map of the neuro-AI intersection.

## Structure

```
NeuroAIParallels/
├── sql/
│   ├── 01_create_tables.sql       DDL — 14 tables, constraints
│   ├── 02_alter_drop.sql          DDL — ALTER / DROP
│   ├── 03_insert_data.sql         DML — dataset
│   ├── 03b_insert_continuation.sql
│   ├── 04_update_delete.sql       DML — UPDATE / DELETE
│   ├── 05_select_queries.sql      36 SELECT queries
│   └── 06_views.sql               analytical views
└── README.md
```

## Conventions

- Comments: `--` intent-comments on non-obvious query logic and each constraint's purpose.
- Foreign keys resolved by subquery name lookup, never hardcoded IDs — portable across re-runs.
- Confidence and bias fields reflect evidence, not opinion.
- All 57 papers, authors, institutions, and DOIs are real published research.
