WITH cleaned AS
(
    SELECT
        repayment_id,
        loan_id,

        repayment_date,

        amount,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY repayment_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.loan_repayment
)

SELECT
    repayment_id,
    loan_id,
    repayment_date,
    amount,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;