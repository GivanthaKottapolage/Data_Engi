DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'bank_olap') THEN
        PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE bank_olap');
    END IF;
END
$$;


CREATE SCHEMA IF NOT EXISTS obt;

CREATE TABLE IF NOT EXISTS obt.customer_value (
    customer_id BIGINT,
    customer_name VARCHAR(255),
    branch_id BIGINT,
    branch_name VARCHAR(255),
    account_id BIGINT,
    balance DECIMAL(18,2),
    loan_id BIGINT,
    loan_amount DECIMAL(18,2)
);



TRUNCATE TABLE obt.customer_value;

-- INSERT INTO obt.customer_value
-- SELECT
--     c.customer_id,
--     CONCAT(c.first_name,' ',c.last_name),
--     b.branch_id,
--     b.name,
--     a.account_id,
--     a.balance,
--     l.loan_id,
--     l.amount
-- FROM core_banking.customer c
-- JOIN core_banking.customer_account ca
--     ON c.customer_id = ca.customer_id
-- JOIN core_banking.account a
--     ON ca.account_id = a.account_id
-- JOIN core_banking.branch b
--     ON a.branch_id = b.branch_id
-- LEFT JOIN loans.loan l
--     ON c.customer_id = l.customer_id;



INSERT INTO obt.customer_value (
    customer_id,
    customer_name,
    branch_id,
    branch_name,
    account_id,
    balance,
    loan_id,
    loan_amount
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.branch_id,
    c.name AS branch_name,
    c.account_id,
    c.balance_clean AS balance,
    l.loan_id,
    l.loan_amount
FROM (
    SELECT
        src.customer_id,
        src.first_name,
        src.last_name,
        src.branch_id,
        src.name,
        src.account_id,
        CASE
            WHEN REPLACE(TRIM(src.balance), ',', '') ~ '^-?[0-9]+(\.[0-9]+)?$'
            THEN REPLACE(TRIM(src.balance), ',', '')::NUMERIC(18,2)
            ELSE NULL
        END AS balance_clean
    FROM dblink(
        'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
        'SELECT
            c.customer_id, c.first_name, c.last_name,
            b.branch_id, b.name,
            a.account_id, a.balance
         FROM core_banking.customer c
         JOIN core_banking.account_ownership ca ON c.customer_id = ca.customer_id
         JOIN core_banking.account a ON ca.account_id = a.account_id
         JOIN core_banking.branch b ON a.branch_id = b.branch_id'
    ) AS src(customer_id INT, first_name TEXT, last_name TEXT,
              branch_id INT, name TEXT, account_id INT, balance TEXT)
) c
LEFT JOIN (
    SELECT
        customer_id,
        loan_id,
        CASE
            WHEN REPLACE(TRIM(amount), ',', '') ~ '^-?[0-9]+(\.[0-9]+)?$'
            THEN REPLACE(TRIM(amount), ',', '')::NUMERIC(18,2)
            ELSE NULL
        END AS loan_amount
    FROM dblink(
        'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
        'SELECT customer_id, loan_id, amount FROM loans.loan'
    ) AS src_loan(customer_id INT, loan_id INT, amount TEXT)
) l ON c.customer_id = l.customer_id;



SELECT
    branch_name,
    SUM(balance) AS total_deposits,
    SUM(COALESCE(loan_amount,0)) AS total_loans,
    SUM(balance) + SUM(COALESCE(loan_amount,0)) AS customer_value
FROM obt.customer_value
GROUP BY branch_name
ORDER BY customer_value DESC;