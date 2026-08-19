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
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.transaction
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';