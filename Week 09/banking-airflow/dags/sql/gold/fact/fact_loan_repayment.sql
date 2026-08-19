INSERT INTO gold.fact_loan_repayment
(
    repayment_id,

    date_key,

    loan_key,
    customer_key,

    repayment_date,

    amount,

    source_system,

    load_timestamp
)

SELECT

    r.repayment_id,

    TO_CHAR(
        r.repayment_date,
        'YYYYMMDD'
    )::INTEGER AS date_key,

    dl.loan_key,

    dc.customer_key,

    r.repayment_date,

    r.amount,

    r.source_system,

    CURRENT_TIMESTAMP

FROM silver.loan_repayment r


-- ===========================================================
-- LOAN SCD2 LOOKUP
-- ===========================================================

LEFT JOIN gold.dim_loan dl

    ON dl.loan_id = r.loan_id

   AND r.repayment_date >= dl.effective_from::DATE

   AND r.repayment_date < dl.effective_to::DATE


-- ===========================================================
-- CUSTOMER SCD2 LOOKUP
-- ===========================================================

LEFT JOIN silver.loan l

    ON l.loan_id = r.loan_id

LEFT JOIN gold.dim_customer dc

    ON dc.customer_id = l.customer_id

   AND r.repayment_date >= dc.effective_from::DATE

   AND r.repayment_date < dc.effective_to::DATE


-- ===========================================================
-- IDEMPOTENCY
-- ===========================================================

WHERE NOT EXISTS
(
    SELECT 1

    FROM gold.fact_loan_repayment existing

    WHERE existing.repayment_id = r.repayment_id
);