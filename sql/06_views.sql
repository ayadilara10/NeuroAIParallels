-- ============================================================
-- NEURO-AI PARALLELS DATABASE
-- Phase 6: Views (Tabele Virtuale)
-- Run each block SEPARATELY
-- ============================================================
SET DEFINE OFF;


-- ============================================================
-- VIEW 1: ACTIONABLE_PARALLELS
-- The intellectual conclusion of the entire database.
-- Surfaces parallels that are:
--   - Well-evidenced (multiple supporting papers)
--   - High or Medium confidence
--   - Supported by diverse methodologies
--   - Flagged for potential funding bias
-- This view answers: WHERE should AI designers look next?
-- ============================================================

-- Step 1: CREATE the view
CREATE OR REPLACE VIEW actionable_parallels AS
SELECT
    fc.category_name,
    par.parallel_name,
    par.parallel_type,
    par.confidence_level,
    bs.bio_name                          AS biological_structure,
    ast.art_name                         AS artificial_structure,
    COUNT(DISTINCT pp.paper_id)          AS supporting_papers,
    COUNT(DISTINCT p.methodology_type)   AS methodology_diversity,
    SUM(CASE WHEN fs.funder_type = 'Industry'
             THEN 1 ELSE 0 END)          AS industry_funded_papers,
    SUBSTR(par.design_insight, 1, 120)   AS insight_preview
FROM parallel par
JOIN functional_category  fc  ON par.category_id  = fc.category_id
JOIN biological_structure bs  ON par.bio_id        = bs.bio_id
JOIN artificial_structure ast ON par.art_id        = ast.art_id
JOIN paper_parallel       pp  ON par.parallel_id   = pp.parallel_id
JOIN paper                p   ON pp.paper_id       = p.paper_id
LEFT JOIN paper_funding   pf  ON p.paper_id        = pf.paper_id
LEFT JOIN funding_source  fs  ON pf.funding_id     = fs.funding_id
WHERE par.confidence_level IN ('High', 'Medium')
GROUP BY
    fc.category_name,
    par.parallel_name,
    par.parallel_type,
    par.confidence_level,
    bs.bio_name,
    ast.art_name,
    par.design_insight;


-- Step 2: SELECT from the view
SELECT category_name,
       parallel_name,
       parallel_type,
       confidence_level,
       supporting_papers,
       methodology_diversity,
       industry_funded_papers,
       insight_preview
FROM actionable_parallels
ORDER BY supporting_papers DESC, confidence_level;


-- ============================================================
-- VIEW 2: RESEARCHER_PROFILE
-- Shows each author with their institution, domain,
-- research impact (h_index), and how many papers
-- they have contributed to this database.
-- Useful for filtering by institutional type or domain.
-- ============================================================

-- Step 1: CREATE the view
CREATE OR REPLACE VIEW researcher_profile AS
SELECT
    a.first_name || ' ' || a.last_name   AS full_name,
    a.primary_domain,
    a.h_index,
    i.institution_name,
    i.institution_type,
    i.country,
    COUNT(DISTINCT pa.paper_id)           AS papers_in_database
FROM author a
LEFT JOIN author_institution ai  ON a.author_id      = ai.author_id
LEFT JOIN institution i          ON ai.institution_id = i.institution_id
LEFT JOIN paper_author pa        ON a.author_id       = pa.author_id
GROUP BY
    a.first_name,
    a.last_name,
    a.primary_domain,
    a.h_index,
    i.institution_name,
    i.institution_type,
    i.country;


-- Step 2: SELECT from the view
SELECT full_name,
       primary_domain,
       h_index,
       institution_name,
       institution_type,
       country,
       papers_in_database
FROM researcher_profile
ORDER BY h_index DESC NULLS LAST;


-- ============================================================
-- VIEW 3: FUNDING_BIAS_REPORT
-- The critical analytical view.
-- For each parallel, shows what percentage of its supporting
-- papers come from industry vs government vs non-profit sources.
-- This directly answers: can we trust this parallel,
-- or is the evidence commercially biased?
-- ============================================================

-- Step 1: CREATE the view
CREATE OR REPLACE VIEW funding_bias_report AS
SELECT
    fc.category_name,
    par.parallel_name,
    par.confidence_level,
    COUNT(DISTINCT pp.paper_id)                          AS total_papers,
    SUM(CASE WHEN fs.funder_type = 'Industry'
             THEN 1 ELSE 0 END)                          AS industry_count,
    SUM(CASE WHEN fs.funder_type = 'Government'
             THEN 1 ELSE 0 END)                          AS government_count,
    SUM(CASE WHEN fs.funder_type = 'Non-profit'
             THEN 1 ELSE 0 END)                          AS nonprofit_count,
    CASE
        WHEN SUM(CASE WHEN fs.funder_type = 'Industry'
                      THEN 1 ELSE 0 END) = 0
        THEN 'Low bias risk'
        WHEN SUM(CASE WHEN fs.funder_type = 'Industry'
                      THEN 1 ELSE 0 END) >= 2
        THEN 'High bias risk — verify independently'
        ELSE 'Moderate bias risk'
    END                                                  AS bias_assessment
FROM parallel par
JOIN functional_category fc  ON par.category_id  = fc.category_id
JOIN paper_parallel      pp  ON par.parallel_id  = pp.parallel_id
JOIN paper               p   ON pp.paper_id      = p.paper_id
LEFT JOIN paper_funding  pf  ON p.paper_id       = pf.paper_id
LEFT JOIN funding_source fs  ON pf.funding_id    = fs.funding_id
GROUP BY
    fc.category_name,
    par.parallel_name,
    par.confidence_level;


-- Step 2: SELECT from the view
SELECT category_name,
       parallel_name,
       confidence_level,
       total_papers,
       industry_count,
       government_count,
       nonprofit_count,
       bias_assessment
FROM funding_bias_report
ORDER BY industry_count DESC, total_papers DESC;


-- ============================================================
-- DEMONSTRATE: CREATE OR REPLACE VIEW (update a view definition)
-- We update RESEARCHER_PROFILE to also show
-- the number of HIGH confidence parallels
-- their papers support
-- ============================================================

CREATE OR REPLACE VIEW researcher_profile AS
SELECT
    a.first_name || ' ' || a.last_name   AS full_name,
    a.primary_domain,
    a.h_index,
    i.institution_name,
    i.institution_type,
    i.country,
    COUNT(DISTINCT pa.paper_id)           AS papers_in_database,
    COUNT(DISTINCT CASE
        WHEN par.confidence_level = 'High'
        THEN par.parallel_id END)         AS high_confidence_parallels
FROM author a
LEFT JOIN author_institution ai  ON a.author_id      = ai.author_id
LEFT JOIN institution i          ON ai.institution_id = i.institution_id
LEFT JOIN paper_author pa        ON a.author_id       = pa.author_id
LEFT JOIN paper_parallel pp      ON pa.paper_id       = pp.paper_id
LEFT JOIN parallel par           ON pp.parallel_id    = par.parallel_id
GROUP BY
    a.first_name,
    a.last_name,
    a.primary_domain,
    a.h_index,
    i.institution_name,
    i.institution_type,
    i.country;


-- SELECT from the updated view
SELECT full_name,
       primary_domain,
       institution_type,
       papers_in_database,
       high_confidence_parallels
FROM researcher_profile
ORDER BY high_confidence_parallels DESC, papers_in_database DESC;


-- ============================================================
-- DEMONSTRATE: DROP VIEW
-- Create a small test view then drop it
-- ============================================================

-- Step 1: Create it
CREATE VIEW temp_view AS
SELECT parallel_name, parallel_type
FROM parallel
WHERE confidence_level = 'High';

-- Step 2: Select from it
SELECT * FROM temp_view;

-- Step 3: Drop it
DROP VIEW temp_view;


-- ============================================================
-- FINAL QUERY: Select from the main view with a WHERE filter
-- Shows only the actionable parallels with 4+ supporting papers
-- This is the database's final answer to its own purpose:
-- WHICH biological insights are ready to be translated into AI design?
-- ============================================================

-- Conclusion slide
SELECT category_name,
       parallel_name,
       biological_structure,
       artificial_structure,
       parallel_type,
       confidence_level,
       supporting_papers,
       industry_funded_papers,
       insight_preview
FROM actionable_parallels
WHERE supporting_papers >= 4
ORDER BY supporting_papers DESC;


-- ============================================================
-- END OF PHASE 6
-- Views created: 3 (ACTIONABLE_PARALLELS, RESEARCHER_PROFILE,
--                   FUNDING_BIAS_REPORT)
-- Demonstrated: CREATE VIEW, CREATE OR REPLACE VIEW, DROP VIEW
-- ============================================================
