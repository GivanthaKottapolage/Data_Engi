WITH cleaned AS
(
    SELECT
        address_id,
        customer_id,

        NULLIF(TRIM(address_type), '') AS address_type,
        NULLIF(TRIM(address_line1), '') AS address_line1,
        NULLIF(TRIM(address_line2), '') AS address_line2,
        NULLIF(TRIM(city), '') AS city,
        NULLIF(TRIM(state), '') AS state,
        NULLIF(TRIM(postal_code), '') AS postal_code,

        is_primary,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY address_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.customer_address
)

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

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;