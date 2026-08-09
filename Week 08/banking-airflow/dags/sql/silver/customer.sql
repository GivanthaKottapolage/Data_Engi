WITH cleaned AS
(
    SELECT
        customer_id,

        TRIM(customer_no) AS customer_no,

        NULLIF(TRIM(nic_number), '') AS nic_number,

        TRIM(first_name) AS first_name,
        TRIM(last_name) AS last_name,

        dob,

        NULLIF(TRIM(gender), '') AS gender,
        NULLIF(TRIM(occupation), '') AS occupation,
        LOWER(NULLIF(TRIM(email), '')) AS email,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.customer
)

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
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;