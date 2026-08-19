-- ===========================================================
-- STEP 1: CLOSE CHANGED CARD RECORDS
-- ===========================================================

UPDATE gold.dim_card AS target

SET
    effective_to = CURRENT_TIMESTAMP,
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP

FROM silver.card AS source

WHERE target.card_id = source.card_id

  AND target.is_current = TRUE

  AND
  (
       target.card_number IS DISTINCT FROM source.card_number
    OR target.account_id IS DISTINCT FROM source.account_id
    OR target.card_type IS DISTINCT FROM source.card_type
    OR target.expiry_date IS DISTINCT FROM source.expiry_date
    OR target.status IS DISTINCT FROM source.status
  );


-- ===========================================================
-- STEP 2: INSERT NEW / CHANGED CARDS
-- ===========================================================

INSERT INTO gold.dim_card
(
    card_id,
    card_number,
    account_id,
    card_type,
    expiry_date,
    status,

    effective_from,
    effective_to,
    is_current,

    created_at,
    updated_at,
    source_system
)

SELECT
    source.card_id,
    source.card_number,
    source.account_id,
    source.card_type,
    source.expiry_date,
    source.status,

    CURRENT_TIMESTAMP,
    TIMESTAMP '9999-12-31 23:59:59',
    TRUE,

    source.created_at,
    source.updated_at,
    source.source_system

FROM silver.card AS source

LEFT JOIN gold.dim_card AS target

    ON target.card_id = source.card_id
    AND target.is_current = TRUE

WHERE target.card_key IS NULL;