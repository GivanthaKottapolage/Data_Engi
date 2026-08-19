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
    created_at,
    updated_at,
    created_by,
    updated_by,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.customer
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';