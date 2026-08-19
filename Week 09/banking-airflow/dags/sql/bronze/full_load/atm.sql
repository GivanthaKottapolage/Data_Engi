SELECT
    *,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CHANNELS' AS source_system
FROM channels.atm;