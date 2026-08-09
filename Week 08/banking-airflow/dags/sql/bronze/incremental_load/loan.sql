SELECT
    loan_id,
    loan_number,
    customer_id,
    amount,
    interest_rate,
    start_date,
    loan_type,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM loans.loan
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';