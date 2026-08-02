SELECT
    address_id,
    customer_id,
    address_type,
    address_line1,
    address_line2,
    city,
    state,
    postal_code,
    is_primary,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.customer_address;