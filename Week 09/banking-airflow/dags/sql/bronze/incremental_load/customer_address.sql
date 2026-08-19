SELECT
    address_id,
    customer_id,
    address_type,
    address_line1,
    address_line2,
    city,
    state,
    postal_code,
    is_primary,
    created_at,
    updated_at,
    created_by,
    updated_by,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.customer_address
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';