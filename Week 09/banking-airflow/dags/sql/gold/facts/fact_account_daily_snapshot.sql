INSERT INTO gold.fact_account_daily_snapshot
(
    snapshot_date_key,
    account_key,
    account_id,
    balance,
    snapshot_date,
    load_timestamp
)

SELECT

    TO_CHAR(
        CURRENT_DATE,
        'YYYYMMDD'
    )::INTEGER AS snapshot_date_key,

    da.account_key,

    a.account_id,

    a.balance,

    CURRENT_DATE,

    CURRENT_TIMESTAMP

FROM silver.account a

JOIN gold.dim_account da

    ON da.account_id = a.account_id

   AND da.is_current = TRUE

ON CONFLICT (
    snapshot_date_key,
    account_key
)

DO UPDATE
SET
    balance = EXCLUDED.balance,
    load_timestamp = CURRENT_TIMESTAMP;