WITH cleaned AS
(
    SELECT
        merchant_id,
        NULLIF(TRIM(merchant_name), '') AS merchant_name,
        NULLIF(TRIM(category), '') AS category,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY merchant_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.merchant
)

SELECT
    merchant_id,
    merchant_name,
    category,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;