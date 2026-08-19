-- ===========================================================
-- STEP 1: CLOSE CHANGED LOAN RECORDS
-- ===========================================================

UPDATE gold.dim_loan AS target

SET
    effective_to = CURRENT_TIMESTAMP,
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP

FROM silver.loan AS source

WHERE target.loan_id = source.loan_id

  AND target.is_current = TRUE

  AND
  (
       target.loan_number IS DISTINCT FROM source.loan_number
    OR target.customer_id IS DISTINCT FROM source.customer_id
    OR target.loan_type IS DISTINCT FROM source.loan_type
    OR target.start_date IS DISTINCT FROM source.start_date
    OR target.interest_rate IS DISTINCT FROM source.interest_rate
  );


-- ===========================================================
-- STEP 2: INSERT NEW / CHANGED LOANS
-- ===========================================================

INSERT INTO gold.dim_loan
(
    loan_id,
    loan_number,
    customer_id,
    loan_type,
    start_date,
    interest_rate,

    effective_from,
    effective_to,
    is_current,

    created_at,
    updated_at,
    source_system
)

SELECT
    source.loan_id,
    source.loan_number,
    source.customer_id,
    source.loan_type,
    source.start_date,
    source.interest_rate,

    CURRENT_TIMESTAMP,
    TIMESTAMP '9999-12-31 23:59:59',
    TRUE,

    source.created_at,
    source.updated_at,
    source.source_system

FROM silver.loan AS source

LEFT JOIN gold.dim_loan AS target

    ON target.loan_id = source.loan_id
    AND target.is_current = TRUE

WHERE target.loan_key IS NULL;