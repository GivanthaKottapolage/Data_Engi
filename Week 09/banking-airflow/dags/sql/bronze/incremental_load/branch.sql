SELECT
    branch_id,
    branch_code,
    name,
    address,
    ifsc_code,
    created_at,
    updated_at,
    created_by,
    updated_by,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.branch
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';