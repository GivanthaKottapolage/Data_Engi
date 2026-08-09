WITH cleaned AS
(
    SELECT
        account_id,
        TRIM(account_number) AS account_number,

        balance,

        opening_date,

        NULLIF(TRIM(status), '') AS status,

        branch_id,

        NULLIF(TRIM(account_type), '') AS account_type,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY account_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.account
)

SELECT
    account_id,
    account_number,
    balance,
    opening_date,
    status,
    branch_id,
    account_type,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned

WHERE rn = 1;