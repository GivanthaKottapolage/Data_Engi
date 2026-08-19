SELECT
    repayment_id,
    loan_id,
    repayment_date,
    amount,
    created_at,
    updated_at,
    created_by,
    updated_by,
    CURRENT_TIMESTAMP AS load_timestamp,
    'LOANS' AS source_system
FROM loans.loan_repayment
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';