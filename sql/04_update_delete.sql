-- ============================================================
-- NEURO-AI PARALLELS DATABASE
-- Phase 6: DML - UPDATE and DELETE
-- Run each block SEPARATELY
-- ============================================================


-- ============================================================
-- BEFORE RUNNING UPDATES: verify current state
-- It shows the values you are about to change
-- ============================================================
SELECT paper_id, title, methodology_type, publication_year
FROM paper
WHERE title IN (
    'The structure dilemma in biological and artificial neural networks',
    'Predicting brain activity using Transformers'
);


-- ============================================================
-- UPDATE 1: Modify a methodology type
-- The paper by Pircher et al. (2021) was classified as
-- Computational but it contains both experimental connectome
-- analysis and computational modeling. We correct it to Mixed.
-- ============================================================
UPDATE paper
SET methodology_type = 'Mixed'
WHERE title = 'The structure dilemma in biological and artificial neural networks';


-- ============================================================
-- UPDATE 2: Correct a publication year
-- The Predicting brain activity using Transformers paper
-- was a 2023 bioRxiv preprint formally published in 2024.
-- We update the year to reflect the final publication.
-- ============================================================
UPDATE paper
SET publication_year = 2024,
    journal = 'PLOS Computational Biology'
WHERE title = 'Predicting brain activity using Transformers';


-- ============================================================
-- AFTER UPDATES: verify the changes were applied
-- ============================================================
SELECT paper_id, title, methodology_type, publication_year, journal
FROM paper
WHERE title IN (
    'The structure dilemma in biological and artificial neural networks',
    'Predicting brain activity using Transformers'
);


-- ============================================================
-- UPDATE 3: Update an author h-index
-- Guillaume Etter is a newer researcher. We update his
-- h-index to reflect a more recent count.
-- ============================================================
UPDATE author
SET h_index = 7
WHERE first_name = 'Guillaume' AND last_name = 'Etter';


-- ============================================================
-- UPDATE 4: Update confidence level on a parallel
-- After reviewing more recent literature, the parallel
-- between Hippocampus and LSTM is now better supported.
-- We upgrade it from Medium to High.
-- ============================================================
UPDATE parallel
SET confidence_level = 'High'
WHERE parallel_name = 'Hippocampal Gating and LSTM Gates';


-- ============================================================
-- BEFORE DELETE: verify the row exists
-- ============================================================
SELECT p.paper_id, p.title, pf.grant_year, f.funder_name
FROM paper p
JOIN paper_funding pf ON p.paper_id = pf.paper_id
JOIN funding_source f  ON pf.funding_id = f.funding_id
WHERE p.title = 'Toward an integration of deep learning and neuroscience'
AND f.funder_name = 'DARPA';


-- ============================================================
-- DELETE 1: Remove a funding link
-- After reviewing the original paper, the DARPA funding
-- attribution for Marblestone et al. (2016) could not be
-- confirmed in the acknowledgements. We remove this link.
-- ============================================================
DELETE FROM paper_funding
WHERE paper_id = (
    SELECT paper_id FROM paper
    WHERE title = 'Toward an integration of deep learning and neuroscience'
)
AND funding_id = (
    SELECT funding_id FROM funding_source
    WHERE funder_name = 'DARPA'
);


-- ============================================================
-- DELETE 2: Remove an unverified paper-parallel link
-- The indirect link between RippleNet and the
-- Motor Cortex Seq2Seq parallel is too weak to retain.
-- It was added speculatively and we now remove it.
-- ============================================================
DELETE FROM paper_parallel
WHERE paper_id = (
    SELECT paper_id FROM paper
    WHERE title = 'RippleNet: A Recurrent Neural Network for Sharp Wave Ripple Detection'
)
AND parallel_id = (
    SELECT parallel_id FROM parallel
    WHERE parallel_name = 'Motor Cortex Population Dynamics and Sequence-to-Sequence RNNs'
);


-- ============================================================
-- AFTER DELETES: confirm rows are gone
-- ============================================================
SELECT p.paper_id, f.funder_name
FROM paper p
JOIN paper_funding pf ON p.paper_id = pf.paper_id
JOIN funding_source f  ON pf.funding_id = f.funding_id
WHERE p.title = 'Toward an integration of deep learning and neuroscience'
AND f.funder_name = 'DARPA';

SELECT * FROM paper_parallel
WHERE paper_id = (SELECT paper_id FROM paper WHERE title = 'RippleNet: A Recurrent Neural Network for Sharp Wave Ripple Detection')
AND parallel_id = (SELECT parallel_id FROM parallel WHERE parallel_name = 'Motor Cortex Population Dynamics and Sequence-to-Sequence RNNs');


-- ============================================================
-- END OF PHASE 6
--   1. SELECT before UPDATE 1 and 2 (current state)
--   2. UPDATE 1 confirmation
--   3. UPDATE 2 confirmation
--   4. SELECT after UPDATE 1 and 2 (changed state)
--   5. UPDATE 3 confirmation
--   6. UPDATE 4 confirmation
--   7. SELECT before DELETE 1 (row exists)
--   8. DELETE 1 confirmation
--   9. DELETE 2 confirmation
--  10. SELECT after DELETE 1 (0 rows)
--  11. SELECT after DELETE 2 (0 rows)
-- ============================================================
