SELECT
    branch_id,
    branch_code,
    name,
    address,
    ifsc_code,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.branch;