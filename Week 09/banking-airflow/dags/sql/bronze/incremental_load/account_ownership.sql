SELECT
    customer_id,
    account_id,
    ownership_start_date,
    created_at,
    updated_at,
    created_by,
    updated_by,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.account_ownership
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';