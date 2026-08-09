-- ===========================================================
-- BRONZE LAYER SCHEMA
-- ===========================================================

CREATE SCHEMA IF NOT EXISTS bronze;


-- ===========================================================
-- CUSTOMER
-- Source: core_banking.customer
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.customer
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- CUSTOMER ADDRESS
-- Source: core_banking.customer_address
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.customer_address
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- CUSTOMER PHONE
-- Source: core_banking.customer_phone
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.customer_phone
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- BRANCH
-- Source: core_banking.branch
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.branch
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- EMPLOYEE
-- Source: core_banking.employee
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.employee
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- ACCOUNT
-- Source: core_banking.account
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.account
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- ACCOUNT OWNERSHIP
-- Source: core_banking.account_ownership
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.account_ownership
(
    customer_id BIGINT,
    account_id BIGINT,
    ownership_start_date DATE,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- LOAN
-- Source: loans.loan
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.loan
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- LOAN REPAYMENT
-- Source: loans.loan_repayment
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.loan_repayment
(
    repayment_id BIGINT,
    loan_id BIGINT,
    repayment_date DATE,
    amount DECIMAL(18,2),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- CARD
-- Source: cards.card
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.card
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- ATM
-- Source: channels.atm
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.atm
(
    atm_id BIGINT,
    atm_code VARCHAR(30),
    branch_id BIGINT,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- MERCHANT
-- Source: reference.merchant
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.merchant
(
    merchant_id BIGINT,
    merchant_name VARCHAR(255),
    category VARCHAR(100),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


-- ===========================================================
-- TRANSACTION
-- Source: core_banking.transaction
-- ===========================================================

CREATE TABLE IF NOT EXISTS bronze.transaction
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);