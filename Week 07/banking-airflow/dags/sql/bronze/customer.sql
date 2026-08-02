SELECT
    customer_id,
    customer_no,
    nic_number,
    first_name,
    last_name,
    dob,
    gender,
    occupation,
    email,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.customer;