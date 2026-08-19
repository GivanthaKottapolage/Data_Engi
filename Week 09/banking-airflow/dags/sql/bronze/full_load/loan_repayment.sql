SELECT
    *,
    CURRENT_TIMESTAMP AS load_timestamp,
    'LOANS' AS source_system
FROM loans.loan_repayment;