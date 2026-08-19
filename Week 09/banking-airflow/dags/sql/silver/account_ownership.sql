WITH cleaned AS
(
    SELECT
        customer_id,
        account_id,

        ownership_start_date,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id, account_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.account_ownership
)

SELECT
    customer_id,
    account_id,
    ownership_start_date,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;