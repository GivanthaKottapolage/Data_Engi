SELECT
    repayment_id,
    loan_id,
    repayment_date,
    amount,
    CURRENT_TIMESTAMP AS load_timestamp,
    'LOANS' AS source_system
FROM loans.loan_repayment
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';