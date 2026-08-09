-- ===========================================================
-- SILVER LAYER
-- ===========================================================

CREATE SCHEMA IF NOT EXISTS silver;


-- ===========================================================
-- CUSTOMER
-- Grain: 1 row per customer_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.customer
(
    customer_id BIGINT,
    customer_no VARCHAR(50),
    nic_number VARCHAR(20),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    dob DATE,
    gender VARCHAR(20),
    occupation VARCHAR(100),
    email VARCHAR(255),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- CUSTOMER ADDRESS
-- Grain: 1 row per address_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.customer_address
(
    address_id BIGINT,
    customer_id BIGINT,
    address_type VARCHAR(50),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    is_primary BOOLEAN,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- CUSTOMER PHONE
-- Grain: 1 row per phone_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.customer_phone
(
    phone_id BIGINT,
    customer_id BIGINT,
    phone_number VARCHAR(30),
    phone_type VARCHAR(20),
    is_primary BOOLEAN,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- BRANCH
-- Grain: 1 row per branch_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.branch
(
    branch_id BIGINT,
    branch_code VARCHAR(20),
    name VARCHAR(255),
    address VARCHAR(500),
    ifsc_code VARCHAR(20),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- EMPLOYEE
-- Grain: 1 row per employee_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.employee
(
    employee_id BIGINT,
    employee_no VARCHAR(50),
    name VARCHAR(255),
    position VARCHAR(100),
    branch_id BIGINT,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- ACCOUNT
-- Grain: 1 row per account_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.account
(
    account_id BIGINT,
    account_number VARCHAR(50),
    balance DECIMAL(18,2),
    opening_date DATE,
    status VARCHAR(30),
    branch_id BIGINT,
    account_type VARCHAR(50),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- ACCOUNT OWNERSHIP
-- Grain: 1 row per customer_id + account_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.account_ownership
(
    customer_id BIGINT,
    account_id BIGINT,
    ownership_start_date DATE,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- LOAN
-- Grain: 1 row per loan_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.loan
(
    loan_id BIGINT,
    loan_number VARCHAR(50),
    customer_id BIGINT,
    amount DECIMAL(18,2),
    interest_rate DECIMAL(8,4),
    start_date DATE,
    loan_type VARCHAR(50),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- LOAN REPAYMENT
-- Grain: 1 row per repayment_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.loan_repayment
(
    repayment_id BIGINT,
    loan_id BIGINT,
    repayment_date DATE,
    amount DECIMAL(18,2),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- CARD
-- Grain: 1 row per card_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.card
(
    card_id BIGINT,
    card_number VARCHAR(30),
    account_id BIGINT,
    card_type VARCHAR(30),
    expiry_date DATE,
    status VARCHAR(30),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- ATM
-- Grain: 1 row per atm_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.atm
(
    atm_id BIGINT,
    atm_code VARCHAR(30),
    branch_id BIGINT,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- MERCHANT
-- Grain: 1 row per merchant_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.merchant
(
    merchant_id BIGINT,
    merchant_name VARCHAR(255),
    category VARCHAR(100),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


-- ===========================================================
-- TRANSACTION
-- Grain: 1 row per transaction_id
-- ===========================================================

CREATE TABLE IF NOT EXISTS silver.transaction
(
    transaction_id BIGINT,
    transaction_timestamp TIMESTAMP,
    amount DECIMAL(18,2),
    transaction_type VARCHAR(50),
    channel VARCHAR(50),
    reference_no VARCHAR(100),

    account_id BIGINT,
    card_id BIGINT,
    atm_id BIGINT,
    merchant_id BIGINT,
    employee_id BIGINT,
    loan_id BIGINT,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);


CREATE TABLE IF NOT EXISTS silver.customer_profile
(
    customer_id BIGINT,
    customer_no VARCHAR(50),
    nic_number VARCHAR(20),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    dob DATE,
    gender VARCHAR(20),
    occupation VARCHAR(100),
    email VARCHAR(255),

    primary_address_line1 VARCHAR(255),
    primary_address_line2 VARCHAR(255),
    primary_city VARCHAR(100),
    primary_state VARCHAR(100),
    primary_postal_code VARCHAR(20),

    primary_phone_number VARCHAR(30),
    primary_phone_type VARCHAR(20),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP,
    source_system VARCHAR(50)
);