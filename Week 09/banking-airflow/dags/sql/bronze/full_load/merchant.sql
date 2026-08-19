SELECT
    *,
    CURRENT_TIMESTAMP AS load_timestamp,
    'REFERENCE' AS source_system
FROM reference.merchant;