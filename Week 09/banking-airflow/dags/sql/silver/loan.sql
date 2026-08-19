WITH cleaned AS
(
    SELECT
        loan_id,
        TRIM(loan_number) AS loan_number,
        customer_id,

        amount,

        interest_rate,

        start_date,

        NULLIF(TRIM(loan_type), '') AS loan_type,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY loan_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.loan
)

SELECT
    loan_id,
    loan_number,
    customer_id,
    amount,
    interest_rate,
    start_date,
    loan_type,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;