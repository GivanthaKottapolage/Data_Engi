-- ===========================================================
-- STEP 1: CLOSE CHANGED ACCOUNT ATTRIBUTES
-- ===========================================================

UPDATE gold.dim_account AS target

SET
    effective_to = CURRENT_TIMESTAMP,
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP

FROM silver.account AS source

WHERE target.account_id = source.account_id

  AND target.is_current = TRUE

  AND
  (
       target.account_number IS DISTINCT FROM source.account_number
    OR target.opening_date IS DISTINCT FROM source.opening_date
    OR target.status IS DISTINCT FROM source.status
    OR target.branch_id IS DISTINCT FROM source.branch_id
    OR target.account_type IS DISTINCT FROM source.account_type
  );


-- ===========================================================
-- STEP 2: INSERT NEW / CHANGED ACCOUNTS
-- ===========================================================

INSERT INTO gold.dim_account
(
    account_id,
    account_number,
    opening_date,
    status,
    branch_id,
    account_type,

    effective_from,
    effective_to,
    is_current,

    created_at,
    updated_at,
    source_system
)

SELECT
    source.account_id,
    source.account_number,
    source.opening_date,
    source.status,
    source.branch_id,
    source.account_type,

    CURRENT_TIMESTAMP,
    TIMESTAMP '9999-12-31 23:59:59',
    TRUE,

    source.created_at,
    source.updated_at,
    source.source_system

FROM silver.account AS source

LEFT JOIN gold.dim_account AS target

    ON target.account_id = source.account_id
    AND target.is_current = TRUE

WHERE target.account_key IS NULL;