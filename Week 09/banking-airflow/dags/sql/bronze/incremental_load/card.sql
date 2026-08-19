SELECT
    card_id,
    card_number,
    account_id,
    card_type,
    expiry_date,
    status,
    created_at,
    updated_at,
    created_by,
    updated_by,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CARDS' AS source_system
FROM cards.card
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';