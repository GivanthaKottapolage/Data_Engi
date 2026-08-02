SELECT
    phone_id,
    customer_id,
    phone_number,
    phone_type,
    is_primary,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.customer_phone;