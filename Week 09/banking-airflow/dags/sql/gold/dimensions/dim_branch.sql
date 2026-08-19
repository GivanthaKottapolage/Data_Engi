INSERT INTO gold.dim_branch
(
    branch_id,
    branch_code,
    name,
    address,
    ifsc_code,
    created_at,
    updated_at,
    source_system
)
SELECT
    branch_id,
    branch_code,
    name,
    address,
    ifsc_code,
    created_at,
    updated_at,
    source_system
FROM silver.branch

ON CONFLICT (branch_id)
DO UPDATE
SET
    branch_code = EXCLUDED.branch_code,
    name = EXCLUDED.name,
    address = EXCLUDED.address,
    ifsc_code = EXCLUDED.ifsc_code,
    updated_at = EXCLUDED.updated_at,
    source_system = EXCLUDED.source_system;