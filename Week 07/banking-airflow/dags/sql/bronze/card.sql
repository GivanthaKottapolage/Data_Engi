SELECT
    card_id,
    card_number,
    account_id,
    card_type,
    expiry_date,
    status,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CARDS' AS source_system
FROM cards.card;