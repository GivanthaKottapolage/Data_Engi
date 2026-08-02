SELECT
    account_id,
    account_number,
    balance,
    opening_date,
    status,
    branch_id,
    account_type,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.account;