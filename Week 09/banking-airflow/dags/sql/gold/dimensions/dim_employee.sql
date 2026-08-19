-- ===========================================================
-- STEP 1: CLOSE CHANGED CURRENT RECORDS
-- ===========================================================

UPDATE gold.dim_employee AS target

SET
    effective_to = CURRENT_TIMESTAMP,
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP

FROM silver.employee AS source

WHERE target.employee_id = source.employee_id

  AND target.is_current = TRUE

  AND
  (
       target.employee_no IS DISTINCT FROM source.employee_no
    OR target.name IS DISTINCT FROM source.name
    OR target.position IS DISTINCT FROM source.position
    OR target.branch_id IS DISTINCT FROM source.branch_id
  );


-- ===========================================================
-- STEP 2: INSERT NEW / CHANGED RECORDS
-- ===========================================================

INSERT INTO gold.dim_employee
(
    employee_id,
    employee_no,
    name,
    position,
    branch_id,

    effective_from,
    effective_to,
    is_current,

    created_at,
    updated_at,
    source_system
)

SELECT
    source.employee_id,
    source.employee_no,
    source.name,
    source.position,
    source.branch_id,

    CURRENT_TIMESTAMP,
    TIMESTAMP '9999-12-31 23:59:59',
    TRUE,

    source.created_at,
    source.updated_at,
    source.source_system

FROM silver.employee AS source

LEFT JOIN gold.dim_employee AS target

    ON target.employee_id = source.employee_id
    AND target.is_current = TRUE

WHERE target.employee_key IS NULL;