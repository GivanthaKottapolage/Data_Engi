SELECT
    *,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM loans.loan;