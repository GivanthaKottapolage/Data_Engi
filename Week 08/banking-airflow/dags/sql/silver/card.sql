WITH cleaned AS
(
    SELECT
        card_id,
        TRIM(card_number) AS card_number,
        account_id,
        NULLIF(TRIM(card_type), '') AS card_type,

        expiry_date,

        NULLIF(TRIM(status), '') AS status,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY card_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.card
)

SELECT
    card_id,
    card_number,
    account_id,
    card_type,
    expiry_date,
    status,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;