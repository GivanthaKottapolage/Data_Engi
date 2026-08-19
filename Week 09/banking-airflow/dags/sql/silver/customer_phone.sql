WITH cleaned AS
(
    SELECT
        phone_id,
        customer_id,

        NULLIF(TRIM(phone_number), '') AS phone_number,
        NULLIF(TRIM(phone_type), '') AS phone_type,

        is_primary,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY phone_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.customer_phone
)

SELECT
    phone_id,
    customer_id,
    phone_number,
    phone_type,
    is_primary,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;