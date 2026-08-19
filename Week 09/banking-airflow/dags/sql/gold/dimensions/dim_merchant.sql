INSERT INTO gold.dim_merchant
(
    merchant_id,
    merchant_name,
    category,
    created_at,
    updated_at,
    source_system
)

SELECT
    merchant_id,
    merchant_name,
    category,
    created_at,
    updated_at,
    source_system

FROM silver.merchant

ON CONFLICT (merchant_id)
DO UPDATE
SET
    merchant_name = EXCLUDED.merchant_name,
    category = EXCLUDED.category,
    updated_at = EXCLUDED.updated_at,
    source_system = EXCLUDED.source_system;