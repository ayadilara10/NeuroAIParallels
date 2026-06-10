-- ============================================================
-- NEURO-AI PARALLELS DATABASE
-- Phase: ALTER TABLE Examples
-- Phase: DROP TABLE Example
-- Run each block SEPARATELY
-- ============================================================


-- ============================================================
-- ALTER 1: ADD a new column
-- We add open_access to the PAPER table.
-- Many neuro-AI papers are published open access;
-- this flag lets us filter for freely available research.
-- ============================================================
ALTER TABLE paper
ADD open_access CHAR(1) DEFAULT 'N';


-- ============================================================
-- ALTER 2: MODIFY an existing column
-- We expand the keywords column in PAPER from 500 to 1000
-- characters. Real papers often have many keywords.
-- ============================================================
ALTER TABLE paper
MODIFY keywords VARCHAR2(1000);


-- ============================================================
-- ALTER 3: ADD a named CHECK CONSTRAINT
-- We add a constraint to AUTHOR ensuring h_index
-- cannot exceed 300 (a practical upper bound for
-- any researcher's citation impact score).
-- ============================================================
ALTER TABLE author
ADD CONSTRAINT chk_hindex_max CHECK (h_index <= 300);


-- ============================================================
-- ALTER 4: DROP the column we added in ALTER 1
-- We remove open_access after deciding it belongs
-- in a separate access rights table in the future.
-- This demonstrates the full column lifecycle.
-- ============================================================
ALTER TABLE paper
DROP COLUMN open_access;


-- ============================================================
-- Phase 4: DROP TABLE Example
-- We create a small temporary test table, verify it exists,
-- then drop it. This demonstrates the DROP command without
-- affecting any real table in the schema.
-- ============================================================

-- Step 1: Create the temporary table
CREATE TABLE temp_test (
    test_id   NUMBER GENERATED ALWAYS AS IDENTITY,
    test_note VARCHAR2(100),
    CONSTRAINT pk_temp_test PRIMARY KEY (test_id)
);

-- Step 2: Confirm it exists
SELECT table_name
FROM user_tables
WHERE table_name = 'TEMP_TEST';

-- Step 3: Drop it
DROP TABLE temp_test;

-- Step 4: Confirm it is gone
SELECT table_name
FROM user_tables
WHERE table_name = 'TEMP_TEST';


-- ============================================================
