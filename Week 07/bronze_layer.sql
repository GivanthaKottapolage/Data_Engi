CREATE TABLE bronze.customer
(
    customer_id BIGINT,
    customer_no VARCHAR(50),
    nic_number VARCHAR(20),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    dob VARCHAR(100),
    gender VARCHAR(20),
    occupation VARCHAR(100),
    email VARCHAR(255),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


CREATE TABLE bronze.customer_address
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


CREATE TABLE bronze.customer_phone
(
    phone_id BIGINT,
    customer_id BIGINT,
    phone_number VARCHAR(30),
    phone_type VARCHAR(20),
    is_primary BOOLEAN,

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);



CREATE TABLE bronze.branch
(
    branch_id BIGINT,
    branch_code VARCHAR(20),
    name VARCHAR(255),
    address VARCHAR(500),
    ifsc_code VARCHAR(20),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


CREATE TABLE bronze.employee
(
    employee_id BIGINT,
    employee_no VARCHAR(50),
    name VARCHAR(255),
    position VARCHAR(100),
    branch_id BIGINT,

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);




CREATE TABLE bronze.account
(
    account_id BIGINT,
    account_number VARCHAR(50),
    balance VARCHAR(50),
    opening_date VARCHAR(50),
    status VARCHAR(30),
    branch_id BIGINT,
    account_type VARCHAR(50),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


CREATE TABLE bronze.account_ownership
(
    customer_id BIGINT,
    account_id BIGINT,
    ownership_start_date VARCHAR(50),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


CREATE TABLE bronze.loan
(
    loan_id BIGINT,
    loan_number VARCHAR(50),
    customer_id BIGINT,
    amount VARCHAR(50),
    interest_rate DECIMAL(8,4),
    start_date VARCHAR(50),
    loan_type VARCHAR(50),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);



CREATE TABLE bronze.loan_repayment
(
    repayment_id BIGINT,
    loan_id BIGINT,
    repayment_date VARCHAR(50),
    amount DECIMAL(18,2),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);



CREATE TABLE bronze.card
(
    card_id BIGINT,
    card_number VARCHAR(30),
    account_id BIGINT,
    card_type VARCHAR(30),
    expiry_date VARCHAR(50),
    status VARCHAR(30),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);



CREATE TABLE bronze.atm
(
    atm_id BIGINT,
    atm_code VARCHAR(30),
    branch_id BIGINT,

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);


CREATE TABLE bronze.merchant
(
    merchant_id BIGINT,
    merchant_name VARCHAR(255),
    category VARCHAR(100),

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);



CREATE TABLE bronze.transaction
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

    load_timestamp TIMESTAMP NOT NULL,
    source_system VARCHAR(50) NOT NULL
);