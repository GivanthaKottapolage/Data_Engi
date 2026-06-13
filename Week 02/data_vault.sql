DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'bank_olap') THEN
        PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE bank_olap');
    END IF;
END
$$;


CREATE SCHEMA IF NOT EXISTS data_vault;

CREATE TABLE IF NOT EXISTS data_vault.hub_customer (
    customer_id BIGINT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS data_vault.hub_branch (
    branch_id BIGINT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS data_vault.hub_account (
    account_id BIGINT PRIMARY KEY
);


CREATE TABLE IF NOT EXISTS data_vault.link_account_ownership (
    customer_id BIGINT,
    account_id BIGINT
);

CREATE TABLE IF NOT EXISTS data_vault.link_account_branch (
    account_id BIGINT,
    branch_id BIGINT
);

CREATE TABLE IF NOT EXISTS data_vault.sat_customer (
    customer_id BIGINT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    occupation VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS data_vault.sat_account (
    account_id BIGINT,
    balance DECIMAL(18,2)
);

CREATE TABLE IF NOT EXISTS data_vault.sat_branch (
    branch_id BIGINT,
    branch_name VARCHAR(255)
);



TRUNCATE TABLE data_vault.sat_branch;
TRUNCATE TABLE data_vault.sat_account;
TRUNCATE TABLE data_vault.sat_customer;
TRUNCATE TABLE data_vault.link_account_branch;
TRUNCATE TABLE data_vault.link_account_ownership;
TRUNCATE TABLE data_vault.hub_account;
TRUNCATE TABLE data_vault.hub_branch;
TRUNCATE TABLE data_vault.hub_customer;

-- hub_customer
INSERT INTO data_vault.hub_customer (customer_id)
SELECT customer_id
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT customer_id FROM core_banking.customer'
) AS src(customer_id INT);

-- hub_branch
INSERT INTO data_vault.hub_branch (branch_id)
SELECT branch_id
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT branch_id FROM core_banking.branch'
) AS src(branch_id INT);

-- hub_account
INSERT INTO data_vault.hub_account (account_id)
SELECT account_id
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT account_id FROM core_banking.account'
) AS src(account_id INT);



-- link_customer_account
INSERT INTO data_vault.link_account_ownership (customer_id, account_id)
SELECT customer_id, account_id
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT customer_id, account_id FROM core_banking.account_ownership  '
) AS src(customer_id INT, account_id INT);

-- link_account_branch
INSERT INTO data_vault.link_account_branch (account_id, branch_id)
SELECT account_id, branch_id
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT account_id, branch_id FROM core_banking.account'
) AS src(account_id INT, branch_id INT);




-- sat_customer
INSERT INTO data_vault.sat_customer (customer_id, first_name, last_name, occupation)
SELECT customer_id, first_name, last_name, occupation
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT customer_id, first_name, last_name, occupation FROM core_banking.customer'
) AS src(customer_id INT, first_name TEXT, last_name TEXT, occupation TEXT);





-- sat_account
INSERT INTO data_vault.sat_account (account_id, balance)
SELECT
    account_id,
    CASE
        WHEN REPLACE(TRIM(balance), ',', '') ~ '^-?[0-9]+(\.[0-9]+)?$'
        THEN REPLACE(TRIM(balance), ',', '')::NUMERIC(18,2)
        ELSE NULL
    END AS balance
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT account_id, balance FROM core_banking.account'
) AS src(account_id INT, balance TEXT);

-- sat_branch
INSERT INTO data_vault.sat_branch (branch_id, branch_name)
SELECT branch_id, name
FROM dblink(
    'dbname=bank_oltp host=localhost port=5432 user=postgres password=123456',
    'SELECT branch_id, name FROM core_banking.branch'
) AS src(branch_id INT, name TEXT);



SELECT
    sb.branch_name,
    SUM(sa.balance) AS total_deposits
FROM data_vault.sat_branch sb
JOIN data_vault.link_account_branch lab
    ON sb.branch_id = lab.branch_id
JOIN data_vault.sat_account sa
    ON lab.account_id = sa.account_id
GROUP BY sb.branch_name
ORDER BY total_deposits DESC;