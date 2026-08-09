-- ===========================================================
-- CORE BANKING SCHEMA
-- ===========================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_database WHERE datname = 'bank_oltp'
    ) THEN
        PERFORM dblink_exec(
            'host=localhost port=5432 dbname=postgres user=postgres password=postgres',
            'CREATE DATABASE bank_oltp'
        );
    END IF;
END $$;

CREATE SCHEMA IF NOT EXISTS core_banking;

CREATE TABLE IF NOT EXISTS core_banking.customer (
    customer_id BIGINT PRIMARY KEY,
    customer_no VARCHAR(50) NOT NULL UNIQUE,
    nic_number VARCHAR(20) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    dob DATE,
    gender VARCHAR(20),
    occupation VARCHAR(100),
    email VARCHAR(255),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS core_banking.customer_address (
    address_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    address_type VARCHAR(50),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    is_primary BOOLEAN,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    CONSTRAINT fk_customer_address_customer
        FOREIGN KEY (customer_id)
        REFERENCES core_banking.customer(customer_id)
);

CREATE TABLE IF NOT EXISTS core_banking.customer_phone (
    phone_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    phone_number VARCHAR(30),
    phone_type VARCHAR(20),
    is_primary BOOLEAN,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    CONSTRAINT fk_customer_phone_customer
        FOREIGN KEY (customer_id)
        REFERENCES core_banking.customer(customer_id)
);

CREATE TABLE IF NOT EXISTS core_banking.branch (
    branch_id BIGINT PRIMARY KEY,
    branch_code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(255),
    address VARCHAR(500),
    ifsc_code VARCHAR(20),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS core_banking.employee (
    employee_id BIGINT PRIMARY KEY,
    employee_no VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255),
    position VARCHAR(100),
    branch_id BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    CONSTRAINT fk_employee_branch
        FOREIGN KEY (branch_id)
        REFERENCES core_banking.branch(branch_id)
);

CREATE TABLE IF NOT EXISTS core_banking.account (
    account_id BIGINT PRIMARY KEY,
    account_number VARCHAR(50) NOT NULL UNIQUE,
    balance DECIMAL(18,2),
    opening_date DATE,
    status VARCHAR(30),
    branch_id BIGINT NOT NULL,
    account_type VARCHAR(50),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    CONSTRAINT fk_account_branch
        FOREIGN KEY (branch_id)
        REFERENCES core_banking.branch(branch_id)
);

CREATE TABLE IF NOT EXISTS core_banking.account_ownership (
    customer_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    ownership_start_date DATE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    PRIMARY KEY (customer_id, account_id),

    CONSTRAINT fk_customer_account_customer
        FOREIGN KEY (customer_id)
        REFERENCES core_banking.customer(customer_id),

    CONSTRAINT fk_customer_account_account
        FOREIGN KEY (account_id)
        REFERENCES core_banking.account(account_id)
);

-- ===========================================================
-- LOANS SCHEMA
-- ===========================================================

CREATE SCHEMA IF NOT EXISTS loans;

CREATE TABLE IF NOT EXISTS loans.loan (
    loan_id BIGINT PRIMARY KEY,
    loan_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    amount DECIMAL(18,2),
    interest_rate DECIMAL(8,4),
    start_date DATE,
    loan_type VARCHAR(50),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    CONSTRAINT fk_loan_customer
        FOREIGN KEY (customer_id)
        REFERENCES core_banking.customer(customer_id)
);

CREATE TABLE IF NOT EXISTS loans.loan_repayment (
    repayment_id BIGINT PRIMARY KEY,
    loan_id BIGINT NOT NULL,
    repayment_date DATE,
    amount DECIMAL(18,2),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    CONSTRAINT fk_loan_repayment_loan
        FOREIGN KEY (loan_id)
        REFERENCES loans.loan(loan_id)
);

-- ===========================================================
-- CARDS SCHEMA
-- ===========================================================

CREATE SCHEMA IF NOT EXISTS cards;

CREATE TABLE IF NOT EXISTS cards.card (
    card_id BIGINT PRIMARY KEY,
    card_number VARCHAR(30) NOT NULL UNIQUE,
    account_id BIGINT NOT NULL,
    card_type VARCHAR(30),
    expiry_date DATE,
    status VARCHAR(30),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    CONSTRAINT fk_card_account
        FOREIGN KEY (account_id)
        REFERENCES core_banking.account(account_id)
);

-- ===========================================================
-- CHANNELS SCHEMA
-- ===========================================================

CREATE SCHEMA IF NOT EXISTS channels;

CREATE TABLE IF NOT EXISTS channels.atm (
    atm_id BIGINT PRIMARY KEY,
    atm_code VARCHAR(30) NOT NULL UNIQUE,
    branch_id BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    CONSTRAINT fk_atm_branch
        FOREIGN KEY (branch_id)
        REFERENCES core_banking.branch(branch_id)
);

-- ===========================================================
-- REFERENCE SCHEMA
-- ===========================================================

CREATE SCHEMA IF NOT EXISTS reference;

CREATE TABLE IF NOT EXISTS reference.merchant (
    merchant_id BIGINT PRIMARY KEY,
    merchant_name VARCHAR(255),
    category VARCHAR(100),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- ===========================================================
-- TRANSACTION TABLE
-- ===========================================================

CREATE TABLE IF NOT EXISTS core_banking.transaction (
    transaction_id BIGINT PRIMARY KEY,
    transaction_timestamp TIMESTAMP NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    transaction_type VARCHAR(50),
    channel VARCHAR(50),
    reference_no VARCHAR(100),

    account_id BIGINT,
    card_id BIGINT,
    atm_id BIGINT,
    merchant_id BIGINT,
    employee_id BIGINT,
    loan_id BIGINT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

    CONSTRAINT fk_transaction_account
        FOREIGN KEY (account_id)
        REFERENCES core_banking.account(account_id),

    CONSTRAINT fk_transaction_card
        FOREIGN KEY (card_id)
        REFERENCES cards.card(card_id),

    CONSTRAINT fk_transaction_atm
        FOREIGN KEY (atm_id)
        REFERENCES channels.atm(atm_id),

    CONSTRAINT fk_transaction_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES reference.merchant(merchant_id),

    CONSTRAINT fk_transaction_employee
        FOREIGN KEY (employee_id)
        REFERENCES core_banking.employee(employee_id),

    CONSTRAINT fk_transaction_loan
        FOREIGN KEY (loan_id)
        REFERENCES loans.loan(loan_id)
);