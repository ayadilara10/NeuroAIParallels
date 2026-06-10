-- ============================================================
-- NEURO-AI PARALLELS DATABASE
-- Aya-Dilara | Informatics, UTM Bucharest
-- Phase: DDL - CREATE TABLE Statements
-- 14 tables in strict dependency order
-- Oracle SQL (LiveSQL compatible)
-- ============================================================


-- ============================================================
-- TABLE 1: FUNCTIONAL_CATEGORY
-- The 6 functional domains that organize all parallels.
-- Every biological structure, artificial structure, and
-- parallel belongs to at least one of these categories.
-- ============================================================
CREATE TABLE functional_category (
    category_id   NUMBER        GENERATED ALWAYS AS IDENTITY,
    category_name VARCHAR2(50)  NOT NULL,
    description   VARCHAR2(500),
    CONSTRAINT pk_functional_category PRIMARY KEY (category_id),
    CONSTRAINT uq_category_name       UNIQUE      (category_name)
);


-- ============================================================
-- TABLE 2: BIOLOGICAL_STRUCTURE
-- Brain regions, neural circuits, cellular processes,
-- and neurotransmitter systems studied in neuroscience.
-- ============================================================
CREATE TABLE biological_structure (
    bio_id         NUMBER         GENERATED ALWAYS AS IDENTITY,
    bio_name       VARCHAR2(100)  NOT NULL,
    bio_type       VARCHAR2(50)   NOT NULL,
    description    VARCHAR2(1000),
    brain_location VARCHAR2(100),
    CONSTRAINT pk_biological_structure PRIMARY KEY (bio_id),
    CONSTRAINT uq_bio_name             UNIQUE      (bio_name),
    CONSTRAINT chk_bio_type CHECK (bio_type IN (
        'Brain Region',
        'Cellular Process',
        'Neural Circuit',
        'Neurotransmitter System',
        'Cognitive Mechanism'
    ))
);


-- ============================================================
-- TABLE 3: ARTIFICIAL_STRUCTURE
-- AI architecture components, algorithms, and mechanisms
-- found in modern deep learning and neural networks.
-- ============================================================
CREATE TABLE artificial_structure (
    art_id              NUMBER         GENERATED ALWAYS AS IDENTITY,
    art_name            VARCHAR2(100)  NOT NULL,
    art_type            VARCHAR2(50)   NOT NULL,
    description         VARCHAR2(1000),
    architecture_family VARCHAR2(100),
    CONSTRAINT pk_artificial_structure PRIMARY KEY (art_id),
    CONSTRAINT uq_art_name             UNIQUE      (art_name),
    CONSTRAINT chk_art_type CHECK (art_type IN (
        'Layer Type',
        'Algorithm',
        'Architecture Component',
        'Training Mechanism',
        'Attention Mechanism',
        'Memory Module'
    ))
);


-- ============================================================
-- TABLE 4: BIO_STRUCTURE_CATEGORY
-- Junction table: a biological structure can belong to
-- multiple functional categories (e.g. hippocampus belongs
-- to both Memory and Learning).
-- ============================================================
CREATE TABLE bio_structure_category (
    bio_id      NUMBER NOT NULL,
    category_id NUMBER NOT NULL,
    CONSTRAINT pk_bio_structure_category PRIMARY KEY (bio_id, category_id),
    CONSTRAINT fk_bsc_bio FOREIGN KEY (bio_id)
        REFERENCES biological_structure(bio_id) ON DELETE CASCADE,
    CONSTRAINT fk_bsc_cat FOREIGN KEY (category_id)
        REFERENCES functional_category(category_id) ON DELETE CASCADE
);


-- ============================================================
-- TABLE 5: ART_STRUCTURE_CATEGORY
-- Junction table: an artificial structure can belong to
-- multiple functional categories (e.g. transformer attention
-- spans both Attention and Memory categories).
-- ============================================================
CREATE TABLE art_structure_category (
    art_id      NUMBER NOT NULL,
    category_id NUMBER NOT NULL,
    CONSTRAINT pk_art_structure_category PRIMARY KEY (art_id, category_id),
    CONSTRAINT fk_asc_art FOREIGN KEY (art_id)
        REFERENCES artificial_structure(art_id) ON DELETE CASCADE,
    CONSTRAINT fk_asc_cat FOREIGN KEY (category_id)
        REFERENCES functional_category(category_id) ON DELETE CASCADE
);


-- ============================================================
-- TABLE 6: PARALLEL
-- The central entity of the database.
-- Connects one biological structure to one artificial
-- structure, classifies the type of parallel, and stores
-- the design insight: what the biological side could
-- teach AI architecture.
-- ============================================================
CREATE TABLE parallel (
    parallel_id      NUMBER         GENERATED ALWAYS AS IDENTITY,
    bio_id           NUMBER         NOT NULL,
    art_id           NUMBER         NOT NULL,
    category_id      NUMBER         NOT NULL,
    parallel_name    VARCHAR2(200)  NOT NULL,
    parallel_type    VARCHAR2(20)   NOT NULL,
    design_insight   VARCHAR2(2000),
    confidence_level VARCHAR2(10)   DEFAULT 'Medium',
    date_added       DATE           DEFAULT SYSDATE,
    CONSTRAINT pk_parallel     PRIMARY KEY (parallel_id),
    CONSTRAINT fk_par_bio      FOREIGN KEY (bio_id)
        REFERENCES biological_structure(bio_id),
    CONSTRAINT fk_par_art      FOREIGN KEY (art_id)
        REFERENCES artificial_structure(art_id),
    CONSTRAINT fk_par_cat      FOREIGN KEY (category_id)
        REFERENCES functional_category(category_id),
    CONSTRAINT chk_parallel_type CHECK (parallel_type IN (
        'Structural',
        'Functional',
        'Computational'
    )),
    CONSTRAINT chk_confidence CHECK (confidence_level IN (
        'High',
        'Medium',
        'Low'
    ))
);


-- ============================================================
-- TABLE 7: INSTITUTION
-- Academic universities, industry labs, and government
-- agencies that produce neuro-AI research.
-- ============================================================
CREATE TABLE institution (
    institution_id   NUMBER         GENERATED ALWAYS AS IDENTITY,
    institution_name VARCHAR2(200)  NOT NULL,
    institution_type VARCHAR2(20)   NOT NULL,
    country          VARCHAR2(100),
    city             VARCHAR2(100),
    CONSTRAINT pk_institution    PRIMARY KEY (institution_id),
    CONSTRAINT uq_inst_name      UNIQUE      (institution_name),
    CONSTRAINT chk_inst_type CHECK (institution_type IN (
        'Academic',
        'Industry',
        'Government',
        'Non-profit'
    ))
);


-- ============================================================
-- TABLE 8: FUNDING_SOURCE
-- Who funds the research and what potential bias
-- that funding relationship may introduce.
-- ============================================================
CREATE TABLE funding_source (
    funding_id     NUMBER         GENERATED ALWAYS AS IDENTITY,
    funder_name    VARCHAR2(200)  NOT NULL,
    funder_type    VARCHAR2(20)   NOT NULL,
    country        VARCHAR2(100),
    potential_bias VARCHAR2(500),
    CONSTRAINT pk_funding_source PRIMARY KEY (funding_id),
    CONSTRAINT uq_funder_name    UNIQUE      (funder_name),
    CONSTRAINT chk_funder_type CHECK (funder_type IN (
        'Government',
        'Industry',
        'Non-profit',
        'Private',
        'Mixed'
    ))
);


-- ============================================================
-- TABLE 9: AUTHOR
-- Researchers classified by primary domain.
-- h_index provides a measure of research impact.
-- ============================================================
CREATE TABLE author (
    author_id      NUMBER        GENERATED ALWAYS AS IDENTITY,
    first_name     VARCHAR2(50)  NOT NULL,
    last_name      VARCHAR2(50)  NOT NULL,
    primary_domain VARCHAR2(20)  NOT NULL,
    h_index        NUMBER,
    CONSTRAINT pk_author        PRIMARY KEY (author_id),
    CONSTRAINT chk_author_domain CHECK (primary_domain IN (
        'Neuroscience',
        'AI',
        'Both'
    )),
    CONSTRAINT chk_hindex CHECK (h_index IS NULL OR h_index >= 0)
);


-- ============================================================
-- TABLE 10: PAPER
-- Research papers at the neuro-AI intersection.
-- Stores metadata needed to classify and query papers
-- by methodology, architecture, and publication details.
-- ============================================================
CREATE TABLE paper (
    paper_id            NUMBER         GENERATED ALWAYS AS IDENTITY,
    title               VARCHAR2(500)  NOT NULL,
    publication_year    NUMBER(4)      NOT NULL,
    journal             VARCHAR2(200),
    doi                 VARCHAR2(200),
    methodology_type    VARCHAR2(20)   NOT NULL,
    ai_architecture_ref VARCHAR2(200),
    keywords            VARCHAR2(500),
    abstract_summary    VARCHAR2(2000),
    CONSTRAINT pk_paper      PRIMARY KEY (paper_id),
    CONSTRAINT uq_doi        UNIQUE      (doi),
    CONSTRAINT chk_method    CHECK (methodology_type IN (
        'Computational',
        'Experimental',
        'Theoretical',
        'Review',
        'Mixed'
    )),
    CONSTRAINT chk_pub_year  CHECK (publication_year BETWEEN 1950 AND 2030)
);


-- ============================================================
-- TABLE 11: PAPER_PARALLEL
-- Junction table: which papers provide evidence for
-- which parallels, and what kind of support they offer.
-- ============================================================
CREATE TABLE paper_parallel (
    paper_id     NUMBER       NOT NULL,
    parallel_id  NUMBER       NOT NULL,
    support_type VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_paper_parallel PRIMARY KEY (paper_id, parallel_id),
    CONSTRAINT fk_pp_paper    FOREIGN KEY (paper_id)
        REFERENCES paper(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_pp_parallel FOREIGN KEY (parallel_id)
        REFERENCES parallel(parallel_id) ON DELETE CASCADE,
    CONSTRAINT chk_support_type CHECK (support_type IN (
        'Direct Evidence',
        'Indirect Evidence',
        'Proposes Parallel',
        'Challenges Parallel'
    ))
);


-- ============================================================
-- TABLE 12: PAPER_AUTHOR
-- Junction table: who authored which paper.
-- author_position = 1 means first author.
-- is_corresponding flags the corresponding author.
-- ============================================================
CREATE TABLE paper_author (
    paper_id         NUMBER  NOT NULL,
    author_id        NUMBER  NOT NULL,
    author_position  NUMBER  NOT NULL,
    is_corresponding CHAR(1) DEFAULT 'N',
    CONSTRAINT pk_paper_author  PRIMARY KEY (paper_id, author_id),
    CONSTRAINT fk_pa_paper      FOREIGN KEY (paper_id)
        REFERENCES paper(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_pa_author     FOREIGN KEY (author_id)
        REFERENCES author(author_id) ON DELETE CASCADE,
    CONSTRAINT chk_corresponding CHECK (is_corresponding IN ('Y', 'N')),
    CONSTRAINT chk_position      CHECK (author_position >= 1)
);


-- ============================================================
-- TABLE 13: AUTHOR_INSTITUTION
-- Junction table: which authors are affiliated with
-- which institutions. is_primary flags their main one.
-- ============================================================
CREATE TABLE author_institution (
    author_id        NUMBER   NOT NULL,
    institution_id   NUMBER   NOT NULL,
    affiliation_year NUMBER(4),
    is_primary       CHAR(1)  DEFAULT 'Y',
    CONSTRAINT pk_author_institution PRIMARY KEY (author_id, institution_id),
    CONSTRAINT fk_ai_author FOREIGN KEY (author_id)
        REFERENCES author(author_id) ON DELETE CASCADE,
    CONSTRAINT fk_ai_inst   FOREIGN KEY (institution_id)
        REFERENCES institution(institution_id) ON DELETE CASCADE,
    CONSTRAINT chk_is_primary CHECK (is_primary IN ('Y', 'N'))
);


-- ============================================================
-- TABLE 14: PAPER_FUNDING
-- Junction table: which papers received which funding.
-- grant_year tracks when the funding was awarded.
-- ============================================================
CREATE TABLE paper_funding (
    paper_id   NUMBER NOT NULL,
    funding_id NUMBER NOT NULL,
    grant_year NUMBER(4),
    CONSTRAINT pk_paper_funding PRIMARY KEY (paper_id, funding_id),
    CONSTRAINT fk_pf_paper   FOREIGN KEY (paper_id)
        REFERENCES paper(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_pf_funding FOREIGN KEY (funding_id)
        REFERENCES funding_source(funding_id) ON DELETE CASCADE
);


-- ============================================================
-- Tables created: 14
-- Constraints applied:
--   PRIMARY KEY: 14
--   FOREIGN KEY: 18
--   UNIQUE: 9
--   CHECK: 13
--   DEFAULT: 4
-- ============================================================
