INSERT INTO gold.dim_atm
(
    atm_id,
    atm_code,
    branch_id,
    created_at,
    updated_at,
    source_system
)

SELECT
    atm_id,
    atm_code,
    branch_id,
    created_at,
    updated_at,
    source_system

FROM silver.atm

ON CONFLICT (atm_id)
DO UPDATE
SET
    atm_code = EXCLUDED.atm_code,
    branch_id = EXCLUDED.branch_id,
    updated_at = EXCLUDED.updated_at,
    source_system = EXCLUDED.source_system;