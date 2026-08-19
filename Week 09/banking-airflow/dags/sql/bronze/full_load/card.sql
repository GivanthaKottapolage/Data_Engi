SELECT
    *,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CARDS' AS source_system
FROM cards.card;