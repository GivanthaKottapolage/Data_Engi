SELECT
    atm_id,
    atm_code,
    branch_id,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CHANNELS' AS source_system
FROM channels.atm
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';