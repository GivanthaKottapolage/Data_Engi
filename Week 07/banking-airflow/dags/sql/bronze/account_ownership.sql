SELECT
    customer_id,
    account_id,
    ownership_start_date,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.account_ownership;