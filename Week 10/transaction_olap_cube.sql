DROP MATERIALIZED VIEW IF EXISTS gold.transaction_olap_cube;

CREATE MATERIALIZED VIEW gold.transaction_olap_cube AS

SELECT

    -- =========================================================
    -- DATE DIMENSION
    -- =========================================================

    d.year_number,

    d.quarter_number,

    d.month_number,

    d.day_of_month,


    -- =========================================================
    -- BRANCH DIMENSION
    -- =========================================================

    b.branch_key,

    b.branch_id,

    b.branch_code,

    b.name AS branch_name,


    -- =========================================================
    -- ACCOUNT DIMENSION
    -- =========================================================

    a.account_key,

    a.account_type,

    a.status AS account_status,


    -- =========================================================
    -- MERCHANT DIMENSION
    -- =========================================================

    m.merchant_key,

    m.category AS merchant_category,

    m.merchant_name,


    -- =========================================================
    -- CARD DIMENSION
    -- =========================================================

    c.card_key,

    c.card_type,

    c.status AS card_status,


    -- =========================================================
    -- ATM DIMENSION
    -- =========================================================

    atm.atm_key,

    atm.atm_code,


    -- =========================================================
    -- MEASURES
    -- =========================================================

    COUNT(
        ft.transaction_id
    ) AS transaction_count,

    SUM(
        ft.amount
    ) AS total_transaction_amount,

    AVG(
        ft.amount
    ) AS average_transaction_amount,


    -- =========================================================
    -- CUBE LEVEL INFORMATION
    -- =========================================================

    GROUPING(
        d.year_number,
        d.quarter_number,
        d.month_number,
        d.day_of_month
    ) AS time_grouping_id,

    GROUPING(
        b.branch_key,
        b.branch_id,
        b.branch_code,
        b.name
    ) AS branch_grouping_id,

    GROUPING(
        a.account_key,
        a.account_type,
        a.status
    ) AS account_grouping_id,

    GROUPING(
        m.merchant_key,
        m.category,
        m.merchant_name
    ) AS merchant_grouping_id,

    GROUPING(
        c.card_key,
        c.card_type,
        c.status
    ) AS card_grouping_id,

    GROUPING(
        atm.atm_key,
        atm.atm_code
    ) AS atm_grouping_id


FROM gold.fact_transaction ft


-- =============================================================
-- DATE
-- =============================================================

JOIN gold.dim_date d

    ON ft.date_key = d.date_key


-- =============================================================
-- BRANCH
-- =============================================================

LEFT JOIN gold.dim_branch b

    ON ft.branch_key = b.branch_key


-- =============================================================
-- ACCOUNT
-- =============================================================

LEFT JOIN gold.dim_account a

    ON ft.account_key = a.account_key


-- =============================================================
-- MERCHANT
-- =============================================================

LEFT JOIN gold.dim_merchant m

    ON ft.merchant_key = m.merchant_key


-- =============================================================
-- CARD
-- =============================================================

LEFT JOIN gold.dim_card c

    ON ft.card_key = c.card_key


-- =============================================================
-- ATM
-- =============================================================

LEFT JOIN gold.dim_atm atm

    ON ft.atm_key = atm.atm_key


-- =============================================================
-- CUBE
-- =============================================================

GROUP BY CUBE
(
    (
        d.year_number,
        d.quarter_number,
        d.month_number,
        d.day_of_month
    ),

    (
        b.branch_key,
        b.branch_id,
        b.branch_code,
        b.name
    ),

    (
        a.account_key,
        a.account_type,
        a.status
    ),

    (
        m.merchant_key,
        m.category,
        m.merchant_name
    ),

    (
        c.card_key,
        c.card_type,
        c.status
    ),

    (
        atm.atm_key,
        atm.atm_code
    )
);


-- highest-level aggregate

SELECT
    total_transaction_amount,
    transaction_count,
    average_transaction_amount
FROM gold.transaction_olap_cube
WHERE year_number IS NULL
  AND branch_key IS NULL
  AND account_key IS NULL
  AND merchant_key IS NULL
  AND card_key IS NULL
  AND atm_key IS NULL;



-- — Slice

SELECT
    year_number,
    total_transaction_amount,
    transaction_count
FROM gold.transaction_olap_cube
WHERE year_number = 2026;



-- Dice

SELECT
    year_number,
    branch_name,
    merchant_category,
    total_transaction_amount,
    transaction_count
FROM gold.transaction_olap_cube
WHERE year_number = 2026
  AND branch_name = 'Colombo'
  AND merchant_category = 'Supermarket';

-- Drill Down

SELECT
    year_number,
    SUM(total_transaction_amount)
FROM gold.transaction_olap_cube
WHERE year_number = 2026
GROUP BY year_number;


SELECT
    year_number,
    quarter_number,
    SUM(total_transaction_amount)
FROM gold.transaction_olap_cube
WHERE year_number = 2026
GROUP BY
    year_number,
    quarter_number
ORDER BY
    quarter_number;



SELECT
    year_number,
    quarter_number,
    month_number,
    SUM(total_transaction_amount)
FROM gold.transaction_olap_cube
WHERE year_number = 2026
GROUP BY
    year_number,
    quarter_number,
    month_number
ORDER BY
    quarter_number,
    month_number;