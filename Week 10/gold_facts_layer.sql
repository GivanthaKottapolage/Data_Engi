CREATE TABLE IF NOT EXISTS gold.fact_transaction
(
    transaction_key BIGINT GENERATED ALWAYS AS IDENTITY,

    transaction_id BIGINT NOT NULL,

    date_key INTEGER,

    account_key BIGINT,
    card_key BIGINT,
    atm_key BIGINT,
    merchant_key BIGINT,
    employee_key BIGINT,
    loan_key BIGINT,

    transaction_timestamp TIMESTAMP NOT NULL,

    transaction_type VARCHAR(50),
    channel VARCHAR(50),
    reference_no VARCHAR(100),

    amount DECIMAL(18,2) NOT NULL,

    source_system VARCHAR(50),

    load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_fact_transaction
        PRIMARY KEY (transaction_key),

    CONSTRAINT uq_fact_transaction_transaction_id
        UNIQUE (transaction_id),

    CONSTRAINT fk_fact_transaction_date
        FOREIGN KEY (date_key)
        REFERENCES gold.dim_date(date_key),

    CONSTRAINT fk_fact_transaction_account
        FOREIGN KEY (account_key)
        REFERENCES gold.dim_account(account_key),

    CONSTRAINT fk_fact_transaction_card
        FOREIGN KEY (card_key)
        REFERENCES gold.dim_card(card_key),

    CONSTRAINT fk_fact_transaction_atm
        FOREIGN KEY (atm_key)
        REFERENCES gold.dim_atm(atm_key),

    CONSTRAINT fk_fact_transaction_merchant
        FOREIGN KEY (merchant_key)
        REFERENCES gold.dim_merchant(merchant_key),

    CONSTRAINT fk_fact_transaction_employee
        FOREIGN KEY (employee_key)
        REFERENCES gold.dim_employee(employee_key),

    CONSTRAINT fk_fact_transaction_loan
        FOREIGN KEY (loan_key)
        REFERENCES gold.dim_loan(loan_key)
);



CREATE TABLE IF NOT EXISTS gold.fact_loan_repayment
(
    repayment_key BIGINT GENERATED ALWAYS AS IDENTITY,

    repayment_id BIGINT NOT NULL,

    date_key INTEGER,

    loan_key BIGINT,
    customer_key BIGINT,

    repayment_date DATE NOT NULL,

    amount DECIMAL(18,2) NOT NULL,

    source_system VARCHAR(50),

    load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_fact_loan_repayment
        PRIMARY KEY (repayment_key),

    CONSTRAINT uq_fact_loan_repayment
        UNIQUE (repayment_id),

    CONSTRAINT fk_fact_repayment_date
        FOREIGN KEY (date_key)
        REFERENCES gold.dim_date(date_key),

    CONSTRAINT fk_fact_repayment_loan
        FOREIGN KEY (loan_key)
        REFERENCES gold.dim_loan(loan_key),

    CONSTRAINT fk_fact_repayment_customer
        FOREIGN KEY (customer_key)
        REFERENCES gold.dim_customer(customer_key)
);



CREATE TABLE IF NOT EXISTS gold.fact_account_daily_snapshot
(
    snapshot_date_key INTEGER NOT NULL,

    account_key BIGINT NOT NULL,

    account_id BIGINT NOT NULL,

    balance DECIMAL(18,2),

    snapshot_date DATE NOT NULL,

    load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_fact_account_daily_snapshot
        PRIMARY KEY (
            snapshot_date_key,
            account_key
        ),

    CONSTRAINT fk_snapshot_date
        FOREIGN KEY (snapshot_date_key)
        REFERENCES gold.dim_date(date_key),

    CONSTRAINT fk_snapshot_account
        FOREIGN KEY (account_key)
        REFERENCES gold.dim_account(account_key)
);


ALTER TABLE gold.fact_transaction
ADD COLUMN IF NOT EXISTS branch_key BIGINT;


ALTER TABLE gold.fact_transaction
ADD CONSTRAINT fk_fact_transaction_branch
FOREIGN KEY (branch_key)
REFERENCES gold.dim_branch(branch_key);


UPDATE gold.fact_transaction ft

SET branch_key = db.branch_key

FROM gold.dim_account da

JOIN gold.dim_branch db
    ON db.branch_id = da.branch_id

WHERE ft.account_key = da.account_key

  AND ft.branch_key IS NULL;