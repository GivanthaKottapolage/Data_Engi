INSERT INTO gold.fact_transaction
(
    transaction_id,

    date_key,

    account_key,
    card_key,
    atm_key,
    merchant_key,
    employee_key,
    loan_key,

    transaction_timestamp,

    transaction_type,
    channel,
    reference_no,

    amount,

    source_system,

    load_timestamp
)

SELECT

    t.transaction_id,

    TO_CHAR(
        t.transaction_timestamp,
        'YYYYMMDD'
    )::INTEGER AS date_key,

    da.account_key,
    dc.card_key,
    datm.atm_key,
    dm.merchant_key,
    de.employee_key,
    dl.loan_key,

    t.transaction_timestamp,

    t.transaction_type,
    t.channel,
    t.reference_no,

    t.amount,

    t.source_system,

    CURRENT_TIMESTAMP

FROM silver.transaction t


-- ===========================================================
-- ACCOUNT SCD2 LOOKUP
-- ===========================================================

LEFT JOIN gold.dim_account da

    ON da.account_id = t.account_id

   AND t.transaction_timestamp >= da.effective_from

   AND t.transaction_timestamp < da.effective_to


-- ===========================================================
-- CARD SCD2 LOOKUP
-- ===========================================================

LEFT JOIN gold.dim_card dc

    ON dc.card_id = t.card_id

   AND t.transaction_timestamp >= dc.effective_from

   AND t.transaction_timestamp < dc.effective_to


-- ===========================================================
-- ATM TYPE 1 LOOKUP
-- ===========================================================

LEFT JOIN gold.dim_atm datm

    ON datm.atm_id = t.atm_id


-- ===========================================================
-- MERCHANT TYPE 1 LOOKUP
-- ===========================================================

LEFT JOIN gold.dim_merchant dm

    ON dm.merchant_id = t.merchant_id


-- ===========================================================
-- EMPLOYEE SCD2 LOOKUP
-- ===========================================================

LEFT JOIN gold.dim_employee de

    ON de.employee_id = t.employee_id

   AND t.transaction_timestamp >= de.effective_from

   AND t.transaction_timestamp < de.effective_to


-- ===========================================================
-- LOAN SCD2 LOOKUP
-- ===========================================================

LEFT JOIN gold.dim_loan dl

    ON dl.loan_id = t.loan_id

   AND t.transaction_timestamp >= dl.effective_from

   AND t.transaction_timestamp < dl.effective_to


-- ===========================================================
-- IDEMPOTENCY
-- ===========================================================

WHERE NOT EXISTS
(
    SELECT 1

    FROM gold.fact_transaction existing

    WHERE existing.transaction_id = t.transaction_id
);