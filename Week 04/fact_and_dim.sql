DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'fact_and_dim') THEN
        PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE fact_and_dim');
    END IF;
END
$$;

CREATE SCHEMA IF NOT EXISTS fact_and_dim;


CREATE TABLE IF NOT EXISTS fact_and_dim.dim_date (
    date_key INT PRIMARY KEY,

    full_date DATE,

    day_number INT,
    day_name VARCHAR(20),

    week_number INT,

    month_number INT,
    month_name VARCHAR(20),

    quarter_number INT,

    year_number INT,

    is_weekend BOOLEAN
);


CREATE TABLE IF NOT EXISTS fact_and_dim.dim_branch (

    branch_key BIGSERIAL PRIMARY KEY,

    branch_id BIGINT,

    branch_code VARCHAR(20),

    branch_name VARCHAR(255),

    address VARCHAR(500),

    ifsc_code VARCHAR(20)
);




CREATE TABLE IF NOT EXISTS fact_and_dim.dim_customer (

    customer_key BIGSERIAL PRIMARY KEY,

    customer_id BIGINT,

    customer_no VARCHAR(50),

    nic_number VARCHAR(20),

    full_name VARCHAR(250),

    gender VARCHAR(20),

    occupation VARCHAR(100),

    city VARCHAR(100),

    state VARCHAR(100)
);




CREATE TABLE IF NOT EXISTS fact_and_dim.dim_account (

    account_key BIGSERIAL PRIMARY KEY,

    account_id BIGINT,

    account_number VARCHAR(50),

    account_type VARCHAR(50),

    status VARCHAR(30)
);




CREATE TABLE IF NOT EXISTS fact_and_dim.dim_employee (

    employee_key BIGSERIAL PRIMARY KEY,

    employee_id BIGINT,

    employee_no VARCHAR(50),

    employee_name VARCHAR(255),

    position VARCHAR(100)
);



CREATE TABLE IF NOT EXISTS fact_and_dim.dim_transaction_channel (

    channel_key BIGSERIAL PRIMARY KEY,

    channel_name VARCHAR(50)
);



CREATE TABLE IF NOT EXISTS fact_and_dim.fact_customer_daily_snapshot (

    snapshot_key BIGSERIAL PRIMARY KEY,

    customer_key BIGINT,

    branch_key BIGINT,

    account_key BIGINT,

    date_key INT,

    total_deposit_amount NUMERIC(18,2),

    total_withdrawal_amount NUMERIC(18,2),

    transaction_count INT,

    atm_transaction_count INT,

    mobile_transaction_count INT,

    card_transaction_count INT,

    loan_payment_amount NUMERIC(18,2),

    bank_fee_amount NUMERIC(18,2),

    average_transaction_amount NUMERIC(18,2),

    closing_balance NUMERIC(18,2),

    FOREIGN KEY (customer_key)
        REFERENCES fact_and_dim.dim_customer(customer_key),

    FOREIGN KEY (branch_key)
        REFERENCES fact_and_dim.dim_branch(branch_key),

    FOREIGN KEY (account_key)
        REFERENCES fact_and_dim.dim_account(account_key),

    FOREIGN KEY (date_key)
        REFERENCES fact_and_dim.dim_date(date_key)
);



CREATE TABLE IF NOT EXISTS fact_and_dim.fact_customer_monthly_performance (

    performance_key BIGSERIAL PRIMARY KEY,

    customer_key BIGINT,

    branch_key BIGINT,

    date_key INT,

    total_deposit NUMERIC(18,2),

    total_withdrawal NUMERIC(18,2),

    total_card_spending NUMERIC(18,2),

    total_loan_repayment NUMERIC(18,2),

    total_bank_charges NUMERIC(18,2),

    total_transactions INT,

    atm_transactions INT,

    online_transactions INT,

    average_transaction_amount NUMERIC(18,2),

    active_days INT,

    closing_balance NUMERIC(18,2),

    FOREIGN KEY (customer_key)
        REFERENCES fact_and_dim.dim_customer(customer_key),

    FOREIGN KEY (branch_key)
        REFERENCES fact_and_dim.dim_branch(branch_key),

    FOREIGN KEY (date_key)
        REFERENCES fact_and_dim.dim_date(date_key)
);