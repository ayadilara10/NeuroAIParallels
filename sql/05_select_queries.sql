-- ============================================================
-- NEURO-AI PARALLELS DATABASE
-- Phase 5: SELECT Queries
-- Run each numbered query SEPARATELY
-- ============================================================
SET DEFINE OFF;


-- ============================================================
-- 5A: COMPARISON OPERATORS
-- WHERE clauses using =, >, <, BETWEEN, IN, LIKE, IS NULL
-- ============================================================

-- Query 5A-1: EQUALS (=)
-- Show all parallels of type Structural
SELECT parallel_name, parallel_type, confidence_level
FROM parallel
WHERE parallel_type = 'Structural'
ORDER BY confidence_level;

-- Query 5A-2: GREATER THAN (>)
-- Show all authors with an h_index greater than 50
-- (high-impact researchers in the neuro-AI field)
SELECT first_name, last_name, primary_domain, h_index
FROM author
WHERE h_index > 50
ORDER BY h_index DESC;

-- Query 5A-3: BETWEEN
-- Show all papers published between 2018 and 2022
SELECT title, publication_year, journal, methodology_type
FROM paper
WHERE publication_year BETWEEN 2018 AND 2022
ORDER BY publication_year;

-- Query 5A-4: IN
-- Show all papers that use Computational or Experimental methodology
SELECT title, publication_year, methodology_type, ai_architecture_ref
FROM paper
WHERE methodology_type IN ('Computational', 'Experimental')
ORDER BY methodology_type, publication_year;

-- Query 5A-5: LIKE
-- Show all papers whose title contains the word 'learning'
-- (case-insensitive using UPPER)
SELECT title, publication_year, journal
FROM paper
WHERE UPPER(title) LIKE UPPER('%learning%')
ORDER BY publication_year;

-- Query 5A-6: LIKE with underscore
-- Show all authors whose last name is exactly 5 characters long
SELECT first_name, last_name, primary_domain, h_index
FROM author
WHERE last_name LIKE '_____';

-- Query 5A-7: IS NULL
-- Show all papers that have no DOI recorded
SELECT title, publication_year, journal, methodology_type
FROM paper
WHERE doi IS NULL;

-- Query 5A-8: IS NOT NULL + less than (<)
-- Show all authors with a recorded h_index below 20
-- (emerging researchers in the field)
SELECT first_name, last_name, primary_domain, h_index
FROM author
WHERE h_index IS NOT NULL AND h_index < 20
ORDER BY h_index;


-- ============================================================
-- 5B: GROUP FUNCTIONS AND HAVING
-- COUNT, AVG, MAX, MIN, SUM with GROUP BY and HAVING
-- ============================================================

-- Query 5B-1: COUNT with GROUP BY
-- Count how many papers exist per methodology type
SELECT methodology_type, COUNT(*) AS paper_count
FROM paper
GROUP BY methodology_type
ORDER BY paper_count DESC;

-- Query 5B-2: COUNT with GROUP BY on parallel_type
-- Count how many parallels exist per type (Structural/Functional/Computational)
SELECT parallel_type, COUNT(*) AS total_parallels
FROM parallel
GROUP BY parallel_type
ORDER BY total_parallels DESC;

-- Query 5B-3: AVG with GROUP BY
-- Average h_index per primary domain
-- Shows whether neuroscientists, AI researchers, or cross-domain researchers
-- have higher average research impact
SELECT primary_domain,
       COUNT(*) AS author_count,
       ROUND(AVG(h_index), 1) AS avg_h_index,
       MAX(h_index) AS max_h_index,
       MIN(h_index) AS min_h_index
FROM author
WHERE h_index IS NOT NULL
GROUP BY primary_domain
ORDER BY avg_h_index DESC;

-- Query 5B-4: COUNT with GROUP BY on institution type
-- How many authors come from Academic vs Industry vs Non-profit institutions
SELECT i.institution_type,
       COUNT(DISTINCT ai.author_id) AS author_count
FROM institution i
JOIN author_institution ai ON i.institution_id = ai.institution_id
GROUP BY i.institution_type
ORDER BY author_count DESC;

-- Query 5B-5: HAVING
-- Show only functional categories that have MORE THAN 3 parallels
-- (the most studied neuro-AI intersection areas)
SELECT fc.category_name,
       COUNT(p.parallel_id) AS parallel_count
FROM functional_category fc
JOIN parallel p ON fc.category_id = p.category_id
GROUP BY fc.category_name
HAVING COUNT(p.parallel_id) > 3
ORDER BY parallel_count DESC;

-- Query 5B-6: COUNT with HAVING
-- Show papers that are supported by more than 3 paper-parallel links
-- (the most widely cited parallels)
SELECT par.parallel_name,
       par.parallel_type,
       par.confidence_level,
       COUNT(pp.paper_id) AS supporting_papers
FROM parallel par
JOIN paper_parallel pp ON par.parallel_id = pp.parallel_id
GROUP BY par.parallel_name, par.parallel_type, par.confidence_level
HAVING COUNT(pp.paper_id) > 3
ORDER BY supporting_papers DESC;

-- Query 5B-7: SUM and AVG on publication year
-- Average publication year and total paper count per AI architecture referenced
-- Shows which architectures are most actively studied and how recently
SELECT ai_architecture_ref,
       COUNT(*) AS paper_count,
       ROUND(AVG(publication_year), 0) AS avg_year,
       MIN(publication_year) AS earliest,
       MAX(publication_year) AS latest
FROM paper
WHERE ai_architecture_ref IS NOT NULL
GROUP BY ai_architecture_ref
ORDER BY paper_count DESC;


-- ============================================================
-- 5C: SINGLE-ROW FUNCTIONS
-- Numeric: ROUND, TRUNC
-- Character: UPPER, LOWER, SUBSTR, LENGTH, CONCAT, INSTR
-- Date/Time: SYSDATE, MONTHS_BETWEEN, TO_DATE, EXTRACT
-- ============================================================

-- Query 5C-1: NUMERIC - ROUND and TRUNC
-- Show average h_index per domain rounded and truncated to see the difference
SELECT primary_domain,
       AVG(h_index)              AS raw_avg,
       ROUND(AVG(h_index), 2)    AS rounded_2dec,
       ROUND(AVG(h_index), 0)    AS rounded_integer,
       TRUNC(AVG(h_index), 0)    AS truncated_integer
FROM author
WHERE h_index IS NOT NULL
GROUP BY primary_domain;

-- Query 5C-2: CHARACTER - UPPER, LENGTH, SUBSTR
-- Show paper titles formatted: uppercased, character count, and first 60 chars
SELECT UPPER(methodology_type)          AS method_upper,
       LENGTH(title)                    AS title_length,
       SUBSTR(title, 1, 60) || '...'    AS short_title,
       publication_year
FROM paper
ORDER BY title_length DESC;

-- Query 5C-3: CHARACTER - CONCAT and INSTR
-- Build full author names and check if last name contains a specific letter
SELECT CONCAT(CONCAT(first_name, ' '), last_name)  AS full_name,
       primary_domain,
       h_index,
       INSTR(last_name, 'a')                        AS position_of_a
FROM author
ORDER BY last_name;

-- Query 5C-4: DATE - SYSDATE and MONTHS_BETWEEN
-- Calculate how many months ago each paper was published
-- (approximated from January 1st of the publication year)
SELECT SUBSTR(title, 1, 50) || '...'                        AS short_title,
       publication_year,
       ROUND(MONTHS_BETWEEN(SYSDATE,
             TO_DATE('01-01-' || publication_year, 'DD-MM-YYYY')), 1)
             AS months_since_publication
FROM paper
ORDER BY months_since_publication ASC;

-- Query 5C-5: DATE - EXTRACT and TO_DATE
-- Show when each parallel was added to the database
-- and extract just the year and month
SELECT parallel_name,
       parallel_type,
       date_added,
       EXTRACT(YEAR  FROM date_added) AS added_year,
       EXTRACT(MONTH FROM date_added) AS added_month
FROM parallel
ORDER BY date_added;

-- Query 5C-6: CHARACTER - REPLACE and TRIM
-- Clean up and reformat the ai_architecture_ref field
SELECT title,
       ai_architecture_ref,
       TRIM(UPPER(ai_architecture_ref))   AS cleaned_ref,
       REPLACE(ai_architecture_ref, 'RNN', 'Recurrent Neural Network') AS expanded_ref
FROM paper
WHERE ai_architecture_ref IN ('RNN', 'CNN', 'Transformer')
ORDER BY ai_architecture_ref;


-- ============================================================
-- 5D: CONDITIONAL EXPRESSIONS
-- CASE, DECODE, NVL, NVL2, COALESCE
-- ============================================================

-- Query 5D-1: CASE
-- Classify each parallel's confidence level with a descriptive label
-- and flag whether it is ready to inform AI design
SELECT parallel_name,
       parallel_type,
       confidence_level,
       CASE confidence_level
           WHEN 'High'   THEN 'Ready to inform AI architecture design'
           WHEN 'Medium' THEN 'Promising — requires more experimental validation'
           WHEN 'Low'    THEN 'Speculative — theoretical basis only'
           ELSE               'Unclassified'
       END AS design_readiness
FROM parallel
ORDER BY confidence_level;

-- Query 5D-2: CASE with range conditions
-- Classify papers by publication era
SELECT SUBSTR(title, 1, 50) AS short_title,
       publication_year,
       CASE
           WHEN publication_year < 2000 THEN 'Foundational Era (pre-2000)'
           WHEN publication_year BETWEEN 2000 AND 2015 THEN 'Deep Learning Rise (2000-2015)'
           WHEN publication_year BETWEEN 2016 AND 2020 THEN 'NeuroAI Emergence (2016-2020)'
           WHEN publication_year > 2020 THEN 'Modern NeuroAI (2021+)'
       END AS research_era
FROM paper
ORDER BY publication_year;

-- Query 5D-3: DECODE
-- Decode methodology type into a readable format for non-technical readers
SELECT SUBSTR(title, 1, 50)     AS short_title,
       methodology_type,
       DECODE(methodology_type,
           'Computational', 'Uses simulation or modelling',
           'Experimental',  'Uses biological lab data',
           'Theoretical',   'Uses mathematical proofs',
           'Review',        'Synthesizes existing literature',
           'Mixed',         'Combines multiple methods',
                            'Unknown method'
       ) AS method_description
FROM paper
ORDER BY methodology_type;

-- Query 5D-4: NVL
-- Show all papers replacing NULL doi with a readable placeholder
SELECT SUBSTR(title, 1, 50)       AS short_title,
       publication_year,
       NVL(doi, 'DOI not recorded') AS doi_display,
       NVL(ai_architecture_ref, 'Not architecture-specific') AS architecture
FROM paper
ORDER BY publication_year DESC;

-- Query 5D-5: NVL2
-- NVL2(expr, value_if_not_null, value_if_null)
-- Flag whether each author has a recorded h_index
SELECT first_name,
       last_name,
       primary_domain,
       h_index,
       NVL2(h_index,
            'Impact score recorded: ' || TO_CHAR(h_index),
            'Impact score not yet recorded'
       ) AS impact_status
FROM author
ORDER BY primary_domain, last_name;

-- Query 5D-6: COALESCE
-- Return the first non-null value from a priority list of identifier fields
-- Useful for building a display identifier for each paper
SELECT SUBSTR(title, 1, 50)  AS short_title,
       COALESCE(
           doi,
           journal,
           'No identifier available'
       ) AS best_identifier,
       publication_year
FROM paper
ORDER BY publication_year;

-- Query 5D-7: CASE inside an aggregate (advanced)
-- Count how many papers per category are industry-funded vs government-funded
-- This is the bias analysis at the heart of the database's purpose
SELECT fc.category_name,
       COUNT(DISTINCT pp.paper_id) AS total_papers,
       SUM(CASE WHEN fs.funder_type = 'Industry'    THEN 1 ELSE 0 END) AS industry_funded,
       SUM(CASE WHEN fs.funder_type = 'Government'  THEN 1 ELSE 0 END) AS government_funded,
       SUM(CASE WHEN fs.funder_type = 'Non-profit'  THEN 1 ELSE 0 END) AS nonprofit_funded
FROM functional_category fc
JOIN parallel par         ON fc.category_id  = par.category_id
JOIN paper_parallel pp    ON par.parallel_id = pp.parallel_id
JOIN paper_funding pf     ON pp.paper_id     = pf.paper_id
JOIN funding_source fs    ON pf.funding_id   = fs.funding_id
GROUP BY fc.category_name
ORDER BY total_papers DESC;


-- ============================================================
-- 5E: JOINS
-- INNER JOIN, LEFT OUTER JOIN, multi-table join (3+ tables)
-- ============================================================

-- Query 5E-1: INNER JOIN (2 tables)
-- Show each parallel with its biological structure name
SELECT par.parallel_name,
       par.parallel_type,
       par.confidence_level,
       bs.bio_name,
       bs.bio_type
FROM parallel par
JOIN biological_structure bs ON par.bio_id = bs.bio_id
ORDER BY par.confidence_level DESC, par.parallel_name;

-- Query 5E-2: INNER JOIN (2 tables)
-- Show each parallel with its artificial structure name and architecture family
SELECT par.parallel_name,
       par.parallel_type,
       ast.art_name,
       ast.architecture_family
FROM parallel par
JOIN artificial_structure ast ON par.art_id = ast.art_id
ORDER BY ast.architecture_family, par.parallel_name;

-- Query 5E-3: INNER JOIN (3 tables)
-- Show each parallel with BOTH its biological and artificial structures
-- and the functional category it belongs to
SELECT fc.category_name,
       bs.bio_name          AS biological_side,
       ast.art_name         AS artificial_side,
       par.parallel_type,
       par.confidence_level
FROM parallel par
JOIN biological_structure bs  ON par.bio_id      = bs.bio_id
JOIN artificial_structure ast ON par.art_id      = ast.art_id
JOIN functional_category  fc  ON par.category_id = fc.category_id
ORDER BY fc.category_name, par.confidence_level DESC;

-- Query 5E-4: INNER JOIN (4 tables)
-- Show papers with their authors and institutions
-- The full provenance chain: paper → author → institution
SELECT SUBSTR(p.title, 1, 45)    AS short_title,
       p.publication_year,
       a.first_name || ' ' || a.last_name  AS author_name,
       a.primary_domain,
       i.institution_name,
       i.institution_type
FROM paper p
JOIN paper_author pa       ON p.paper_id      = pa.paper_id
JOIN author a              ON pa.author_id    = a.author_id
JOIN author_institution ai ON a.author_id     = ai.author_id
JOIN institution i         ON ai.institution_id = i.institution_id
ORDER BY p.publication_year DESC, a.last_name;

-- Query 5E-5: LEFT OUTER JOIN
-- Show ALL biological structures and the parallels they appear in
-- LEFT JOIN ensures structures with NO parallel yet are still shown (with NULL)
SELECT bs.bio_name,
       bs.bio_type,
       par.parallel_name,
       par.parallel_type
FROM biological_structure bs
LEFT JOIN parallel par ON bs.bio_id = par.bio_id
ORDER BY bs.bio_name;

-- Query 5E-6: LEFT OUTER JOIN
-- Show ALL papers and their funding (if any)
-- Papers with no funding source recorded will show NULL
SELECT SUBSTR(p.title, 1, 50)         AS short_title,
       p.publication_year,
       NVL(fs.funder_name, 'No funding recorded')   AS funder,
       NVL(fs.funder_type, 'N/A')                   AS funder_type
FROM paper p
LEFT JOIN paper_funding pf   ON p.paper_id    = pf.paper_id
LEFT JOIN funding_source fs  ON pf.funding_id = fs.funding_id
ORDER BY p.publication_year DESC;

-- Query 5E-7: MULTI-TABLE JOIN (5 tables) — the intellectual core query
-- Full pipeline: category → parallel → paper → funding → funder bias
-- Which parallels are supported by industry-funded research?
SELECT fc.category_name,
       par.parallel_name,
       par.confidence_level,
       SUBSTR(p.title, 1, 40)   AS paper_title,
       fs.funder_name,
       fs.funder_type,
       fs.potential_bias
FROM functional_category fc
JOIN parallel par        ON fc.category_id  = par.category_id
JOIN paper_parallel pp   ON par.parallel_id = pp.parallel_id
JOIN paper p             ON pp.paper_id     = p.paper_id
JOIN paper_funding pf    ON p.paper_id      = pf.paper_id
JOIN funding_source fs   ON pf.funding_id   = fs.funding_id
WHERE fs.funder_type = 'Industry'
ORDER BY fc.category_name, par.parallel_name;


-- ============================================================
-- 5F: SUBQUERIES
-- Single-row, multi-row, and correlated subqueries
-- ============================================================

-- Query 5F-1: SINGLE-ROW SUBQUERY
-- Show papers published after the average publication year of all papers
SELECT title, publication_year, methodology_type, journal
FROM paper
WHERE publication_year > (SELECT AVG(publication_year) FROM paper)
ORDER BY publication_year DESC;

-- Query 5F-2: SINGLE-ROW SUBQUERY
-- Show the author with the highest h_index
SELECT first_name, last_name, primary_domain, h_index
FROM author
WHERE h_index = (SELECT MAX(h_index) FROM author);

-- Query 5F-3: MULTI-ROW SUBQUERY with IN
-- Show all papers that support at least one HIGH confidence parallel
SELECT DISTINCT SUBSTR(p.title, 1, 60) AS title,
       p.publication_year,
       p.methodology_type
FROM paper p
WHERE p.paper_id IN (
    SELECT pp.paper_id
    FROM paper_parallel pp
    JOIN parallel par ON pp.parallel_id = par.parallel_id
    WHERE par.confidence_level = 'High'
)
ORDER BY p.publication_year DESC;

-- Query 5F-4: MULTI-ROW SUBQUERY with NOT IN
-- Show biological structures that have NO parallel defined yet
SELECT bio_name, bio_type, brain_location
FROM biological_structure
WHERE bio_id NOT IN (
    SELECT DISTINCT bio_id FROM parallel
)
ORDER BY bio_name;

-- Query 5F-5: MULTI-ROW SUBQUERY with ANY
-- Show authors whose h_index is greater than ANY author from an Industry institution
SELECT a.first_name, a.last_name, a.primary_domain, a.h_index
FROM author a
WHERE a.h_index > ANY (
    SELECT a2.h_index
    FROM author a2
    JOIN author_institution ai ON a2.author_id     = ai.author_id
    JOIN institution i         ON ai.institution_id = i.institution_id
    WHERE i.institution_type = 'Industry'
    AND a2.h_index IS NOT NULL
)
AND a.h_index IS NOT NULL
ORDER BY a.h_index DESC;

-- Query 5F-6: CORRELATED SUBQUERY
-- For each functional category, show how many parallels it contains
-- using a correlated subquery instead of a GROUP BY
SELECT category_name,
       (SELECT COUNT(*)
        FROM parallel par
        WHERE par.category_id = fc.category_id) AS parallel_count
FROM functional_category fc
ORDER BY parallel_count DESC;

-- Query 5F-7: CORRELATED SUBQUERY
-- Show each paper along with the number of parallels it supports
SELECT SUBSTR(p.title, 1, 55) AS short_title,
       p.publication_year,
       p.methodology_type,
       (SELECT COUNT(*)
        FROM paper_parallel pp
        WHERE pp.paper_id = p.paper_id) AS parallels_supported
FROM paper p
ORDER BY parallels_supported DESC, p.publication_year DESC;

-- Query 5F-8: SUBQUERY IN FROM CLAUSE (inline view)
-- Find the top 3 most supported parallels using a subquery in FROM
SELECT parallel_name, parallel_type, confidence_level, supporting_papers
FROM (
    SELECT par.parallel_name,
           par.parallel_type,
           par.confidence_level,
           COUNT(pp.paper_id) AS supporting_papers
    FROM parallel par
    JOIN paper_parallel pp ON par.parallel_id = pp.parallel_id
    GROUP BY par.parallel_name, par.parallel_type, par.confidence_level
    ORDER BY supporting_papers DESC
)
WHERE ROWNUM <= 3;


-- ============================================================
-- 5G: SET OPERATORS
-- UNION, UNION ALL, INTERSECT, MINUS
-- ============================================================

-- Query 5G-1: UNION
-- Combine a list of all biological structure names
-- with all artificial structure names into one unified list
-- UNION removes duplicates (though names should be distinct here)
SELECT bio_name  AS structure_name, 'Biological' AS origin
FROM biological_structure
UNION
SELECT art_name, 'Artificial'
FROM artificial_structure
ORDER BY origin, structure_name;

-- Query 5G-2: UNION ALL
-- List all institutions (with type) that appear in author affiliations
-- UNION ALL keeps duplicates — shows which institutions appear most
SELECT i.institution_name, i.institution_type, i.country
FROM institution i
JOIN author_institution ai ON i.institution_id = ai.institution_id
UNION ALL
SELECT i2.institution_name, i2.institution_type, i2.country
FROM institution i2
JOIN author_institution ai2 ON i2.institution_id = ai2.institution_id
ORDER BY institution_name;

-- Query 5G-3: INTERSECT
-- Find authors who have BOTH:
-- written a paper AND have an institution affiliation recorded
-- (i.e. fully documented researchers in the database)
SELECT a.author_id, a.first_name, a.last_name
FROM author a
JOIN paper_author pa ON a.author_id = pa.author_id
INTERSECT
SELECT a2.author_id, a2.first_name, a2.last_name
FROM author a2
JOIN author_institution ai ON a2.author_id = ai.author_id
ORDER BY last_name;

-- Query 5G-4: MINUS
-- Find authors who are recorded in the database
-- but have NO paper authorship recorded
-- (authors mentioned but not yet linked to papers)
SELECT author_id, first_name, last_name, primary_domain
FROM author
MINUS
SELECT a.author_id, a.first_name, a.last_name, a.primary_domain
FROM author a
JOIN paper_author pa ON a.author_id = pa.author_id
ORDER BY last_name;

-- Query 5G-5: UNION combining papers from two different methodology types
-- with additional label showing which group they fall into
SELECT SUBSTR(title, 1, 55) AS short_title, publication_year,
       'Biological Lab Study' AS study_type
FROM paper
WHERE methodology_type = 'Experimental'
UNION
SELECT SUBSTR(title, 1, 55), publication_year,
       'Computational Simulation'
FROM paper
WHERE methodology_type = 'Computational'
ORDER BY publication_year DESC;

-- Query 5G-6: MINUS
-- Find biological structures that appear in the bio_structure_category table
-- but do NOT have a parallel defined
-- (structures categorized but not yet matched to an AI equivalent)
SELECT bs.bio_name, bs.bio_type
FROM biological_structure bs
WHERE bs.bio_id IN (SELECT bio_id FROM bio_structure_category)
MINUS
SELECT bs2.bio_name, bs2.bio_type
FROM biological_structure bs2
WHERE bs2.bio_id IN (SELECT bio_id FROM parallel)
ORDER BY bio_name;


-- ============================================================
-- END OF PHASE 5
-- Queries written: 36 total
-- Course requirements covered:
--   Comparison operators:   8 queries (5A-1 to 5A-8)
--   Group functions:        7 queries (5B-1 to 5B-7)
--   Single-row functions:   6 queries (5C-1 to 5C-6)
--   Conditional expressions:7 queries (5D-1 to 5D-7)
--   Joins:                  7 queries (5E-1 to 5E-7)
--   Subqueries:             8 queries (5F-1 to 5F-8)
--   Set operators:          6 queries (5G-1 to 5G-6)
-- ============================================================
