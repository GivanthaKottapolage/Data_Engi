WITH cleaned AS
(
    SELECT
        transaction_id,

        transaction_timestamp,

        amount,

        NULLIF(TRIM(transaction_type), '') AS transaction_type,
        NULLIF(TRIM(channel), '') AS channel,
        NULLIF(TRIM(reference_no), '') AS reference_no,

        account_id,
        card_id,
        atm_id,
        merchant_id,
        employee_id,
        loan_id,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY transaction_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.transaction
)

SELECT
    transaction_id,
    transaction_timestamp,
    amount,
    transaction_type,
    channel,
    reference_no,

    account_id,
    card_id,
    atm_id,
    merchant_id,
    employee_id,
    loan_id,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;