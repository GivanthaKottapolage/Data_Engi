SELECT
    merchant_id,
    merchant_name,
    category,
    CURRENT_TIMESTAMP AS load_timestamp,
    'REFERENCE' AS source_system
FROM reference.merchant
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';