DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'bank_olap') THEN
        PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE bank_olap');
    END IF;
END
$$;

CREATE SCHEMA IF NOT EXISTS inmon;

CREATE TABLE IF NOT EXISTS inmon.dim_customer (
    customer_id BIGINT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    occupation VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS inmon.dim_branch (
    branch_id BIGINT PRIMARY KEY,
    branch_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS inmon.fact_account_balance (
    account_id BIGINT,
    customer_id BIGINT,
    branch_id BIGINT,
    balance DECIMAL(18,2)
);

drop table inmon.fact_loan;

CREATE TABLE IF NOT EXISTS inmon.fact_loan (
    loan_id BIGINT,
    customer_id BIGINT,
    loan_amount DECIMAL(18,2)
);

-- ---------------------- create postgres_fdw ------------------------------
--
-- CREATE SERVER core_banking_server
-- FOREIGN DATA WRAPPER postgres_fdw
-- OPTIONS (
--     host 'localhost',
--     port '5432',           -- change if your port is different
--     dbname 'core_banking'
-- );


CREATE EXTENSION IF NOT EXISTS dblink;


----------------- LOAD DATA ----------------------------------------


TRUNCATE TABLE inmon.fact_loan;
TRUNCATE TABLE inmon.fact_account_balance;
TRUNCATE TABLE inmon.dim_customer;
TRUNCATE TABLE inmon.dim_branch;

-- INSERT INTO inmon.dim_customer
-- SELECT
--     customer_id,
--     first_name,
--     last_name,
--     occupation
-- FROM core_banking.customer;

INSERT INTO inmon.dim_customer (customer_id, first_name, last_name, occupation)
SELECT customer_id, first_name, last_name, occupation
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT customer_id, first_name, last_name, occupation FROM core_banking.customer'
) AS src(customer_id INT, first_name TEXT, last_name TEXT, occupation TEXT);


select * from inmon.dim_customer;
--
-- INSERT INTO inmon.dim_branch
-- SELECT
--     branch_id,
--     name
-- FROM core_banking.branch;




INSERT INTO inmon.dim_branch (branch_id, branch_name)
SELECT branch_id, name
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT branch_id, name FROM core_banking.branch'
) AS src(branch_id INT, name TEXT);

-- INSERT INTO inmon.fact_account_balance
-- SELECT
--     a.account_id,
--     ca.customer_id,
--     a.branch_id,
--     CASE
--         WHEN REPLACE(TRIM(a.balance), ',', '') ~ '^-?[0-9]+(\.[0-9]+)?$'
--         THEN REPLACE(TRIM(a.balance), ',', '')::NUMERIC(18,2)
--         ELSE NULL
--     END AS balance
-- FROM core_banking.account a
-- JOIN core_banking.account_ownership ca
--     ON a.account_id = ca.account_id;


INSERT INTO inmon.fact_account_balance (account_id, customer_id, branch_id, balance)
SELECT
    account_id,
    customer_id,
    branch_id,
    CASE
        WHEN REPLACE(TRIM(balance), ',', '') ~ '^-?[0-9]+(\.[0-9]+)?$'
        THEN REPLACE(TRIM(balance), ',', '')::NUMERIC(18,2)
        ELSE NULL
    END AS balance
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT
        a.account_id,
        ca.customer_id,
        a.branch_id,
        a.balance
     FROM core_banking.account a
     JOIN core_banking.account_ownership ca
        ON a.account_id = ca.account_id'
) AS src(
    account_id INT,
    customer_id INT,
    branch_id INT,
    balance TEXT
);





select * from inmon.fact_account_balance;

-- INSERT INTO inmon.fact_loan
-- SELECT
--     loan_id,
--     customer_id,
--     CASE
--         WHEN REPLACE(TRIM(amount), ',', '') ~ '^-?[0-9]+(\.[0-9]+)?$'
--         THEN REPLACE(TRIM(amount), ',', '')::NUMERIC(18,2)
--         ELSE NULL
--     END AS loan_amount
-- FROM loans.loan;
--
-- select * from inmon.fact_loan;


INSERT INTO inmon.fact_loan (loan_id, customer_id, loan_amount)
SELECT
    loan_id,
    customer_id,
    CASE
        WHEN REPLACE(TRIM(amount), ',', '') ~ '^-?[0-9]+(\.[0-9]+)?$'
        THEN REPLACE(TRIM(amount), ',', '')::NUMERIC(18,2)
        ELSE NULL
    END AS loan_amount
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT loan_id, customer_id, amount FROM loans.loan'
) AS src(loan_id INT, customer_id INT, amount TEXT);


-------------------------------------------------------- business query --------------------------------------------


CREATE SCHEMA IF NOT EXISTS marts;

CREATE OR REPLACE VIEW marts.inmon_customer_value AS
SELECT
    b.branch_name,
    SUM(ab.balance) AS total_deposits,
    COALESCE(SUM(l.loan_amount),0) AS total_loans,
    SUM(ab.balance) + COALESCE(SUM(l.loan_amount),0) AS customer_value
FROM inmon.dim_branch b
JOIN inmon.fact_account_balance ab
    ON b.branch_id = ab.branch_id
LEFT JOIN inmon.fact_loan l
    ON ab.customer_id = l.customer_id
GROUP BY b.branch_name
ORDER BY customer_value DESC;


