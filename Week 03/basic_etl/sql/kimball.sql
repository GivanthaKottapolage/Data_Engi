DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'bank_olap') THEN
        PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE bank_olap');
    END IF;
END
$$;



CREATE SCHEMA IF NOT EXISTS kimball;

CREATE TABLE IF NOT EXISTS kimball.dim_branch (
    branch_id BIGINT PRIMARY KEY,
    branch_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS kimball.fact_customer_value (
    branch_id BIGINT,
    deposit_amount DECIMAL(18,2),
    loan_amount DECIMAL(18,2)
);

----    LOAD DATA --------------------


TRUNCATE TABLE kimball.fact_customer_value;
TRUNCATE TABLE kimball.dim_branch;

-- INSERT INTO kimball.dim_branch
-- SELECT
--     branch_id,
--     name
-- FROM core_banking.branch;



INSERT INTO kimball.dim_branch (branch_id, branch_name)
SELECT branch_id, name
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT branch_id, name FROM core_banking.branch'
) AS src(branch_id INT, name TEXT);




-- INSERT INTO kimball.fact_customer_value
-- SELECT
--     a.branch_id,
--     SUM(a.balance),
--     COALESCE(SUM(l.amount),0)
-- FROM core_banking.account a
-- JOIN core_banking.account_ownership ca
--     ON a.account_id = ca.account_id
-- LEFT JOIN loans.loan l
--     ON ca.customer_id = l.customer_id
-- GROUP BY a.branch_id;


INSERT INTO kimball.fact_customer_value (branch_id, deposit_amount, loan_amount)
SELECT
    branch_id,
    SUM(balance) AS total_balance,
    COALESCE(SUM(loan_amount), 0) AS total_loan_amount
FROM (
    SELECT
        src1.branch_id,
        CASE
            WHEN REPLACE(TRIM(src1.balance), ',', '') ~ '^-?[0-9]+(\.[0-9]+)?$'
            THEN REPLACE(TRIM(src1.balance), ',', '')::NUMERIC(18,2)
            ELSE NULL
        END AS balance,
        src1.customer_id
    FROM dblink(
        'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
        'SELECT a.branch_id, a.balance, ca.customer_id
         FROM core_banking.account a
         JOIN core_banking.account_ownership ca ON a.account_id = ca.account_id'
    ) AS src1(branch_id INT, balance TEXT, customer_id INT)
) a
LEFT JOIN (
    SELECT
        customer_id,
        CASE
            WHEN REPLACE(TRIM(amount), ',', '') ~ '^-?[0-9]+(\.[0-9]+)?$'
            THEN REPLACE(TRIM(amount), ',', '')::NUMERIC(18,2)
            ELSE NULL
        END AS loan_amount
    FROM dblink(
        'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
        'SELECT customer_id, amount FROM loans.loan'
    ) AS src2(customer_id INT, amount TEXT)
) l ON a.customer_id = l.customer_id
GROUP BY branch_id;



------------------------------------------------- business query -------------------------------------------------------


CREATE SCHEMA IF NOT EXISTS marts;

CREATE OR REPLACE VIEW marts.kimball_customer_value AS

SELECT
    b.branch_name,
    f.deposit_amount,
    f.loan_amount,
    f.deposit_amount + f.loan_amount AS customer_value
FROM kimball.fact_customer_value f
JOIN kimball.dim_branch b
    ON f.branch_id = b.branch_id
ORDER BY customer_value DESC;