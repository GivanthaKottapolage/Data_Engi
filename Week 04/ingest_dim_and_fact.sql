INSERT INTO fact_and_dim.dim_date
(
    date_key,
    full_date,
    day_number,
    day_name,
    week_number,
    month_number,
    month_name,
    quarter_number,
    year_number,
    is_weekend
)

SELECT

TO_CHAR(d,'YYYYMMDD')::INT,

d,

EXTRACT(DAY FROM d),

TO_CHAR(d,'Day'),

EXTRACT(WEEK FROM d),

EXTRACT(MONTH FROM d),

TO_CHAR(d,'Month'),

EXTRACT(QUARTER FROM d),

EXTRACT(YEAR FROM d),

CASE
WHEN EXTRACT(ISODOW FROM d) IN (6,7)
THEN TRUE
ELSE FALSE
END

FROM generate_series
(
DATE '2025-01-01',
DATE '2027-12-31',
INTERVAL '1 day'
)d;





Truncate table fact_and_dim.dim_branch;




INSERT INTO fact_and_dim.dim_branch
(
    branch_id,
    branch_code,
    branch_name,
    address,
    ifsc_code
)
SELECT
    branch_id,
    branch_code,
    name,
    address,
    ifsc_code
FROM core_banking.branch;




Truncate table fact_and_dim.dim_account;
INSERT INTO fact_and_dim.dim_account
(
    account_id,
    account_number,
    account_type,
    status
)
SELECT
    account_id,
    account_number,
    account_type,
    status
FROM core_banking.account;



TRUNCATE TABLE fact_and_dim.dim_customer;

INSERT INTO fact_and_dim.dim_customer
(
    customer_id,
    customer_no,
    nic_number,
    full_name,
    gender,
    occupation,
    city,
    state
)
SELECT

    c.customer_id,

    c.customer_no,

    c.nic_number,

    CONCAT(c.first_name,' ',c.last_name),

    c.gender,

    c.occupation,

    ca.city,

    ca.state

FROM core_banking.customer c

LEFT JOIN core_banking.customer_address ca

ON c.customer_id=ca.customer_id
AND ca.is_primary=true;





TRUNCATE TABLE fact_and_dim.dim_employee;
INSERT INTO fact_and_dim.dim_employee
(
    employee_id,
    employee_no,
    employee_name,
    position
)
SELECT

employee_id,

employee_no,

name,

position

FROM core_banking.employee;


INSERT INTO fact_and_dim.fact_customer_daily_snapshot
(
customer_key,
branch_key,
account_key,
date_key,

total_deposit_amount,
total_withdrawal_amount,
transaction_count,
atm_transaction_count,
mobile_transaction_count,
card_transaction_count,

average_transaction_amount
)

SELECT

dc.customer_key,

db.branch_key,

da.account_key,

TO_CHAR(t.transaction_timestamp,'YYYYMMDD')::INT,

SUM(
CASE
WHEN t.transaction_type='Deposit'
THEN t.amount
ELSE 0
END
),

SUM(
CASE
WHEN t.transaction_type='Withdrawal'
THEN t.amount
ELSE 0
END
),

COUNT(*),

COUNT(
CASE
WHEN t.atm_id IS NOT NULL
THEN 1
END
),

COUNT(
CASE
WHEN t.channel='Mobile'
THEN 1
END
),

COUNT(
CASE
WHEN t.card_id IS NOT NULL
THEN 1
END
),

AVG(t.amount)

FROM core_banking.transaction t

JOIN core_banking.account a

ON t.account_id=a.account_id

JOIN core_banking.account_ownership ao

ON ao.account_id=a.account_id

JOIN fact_and_dim.dim_customer dc

ON dc.customer_id=ao.customer_id

JOIN fact_and_dim.dim_account da

ON da.account_id=a.account_id

JOIN fact_and_dim.dim_branch db

ON db.branch_id=a.branch_id

GROUP BY

dc.customer_key,

db.branch_key,

da.account_key,

TO_CHAR(t.transaction_timestamp,'YYYYMMDD');





INSERT INTO fact_and_dim.fact_customer_monthly_performance
(
customer_key,
branch_key,
date_key,

total_deposit,
total_withdrawal,
total_transactions,
atm_transactions,
average_transaction_amount
)

SELECT

customer_key,

branch_key,

(date_key/100),

SUM(total_deposit_amount),

SUM(total_withdrawal_amount),

SUM(transaction_count),

SUM(atm_transaction_count),

AVG(average_transaction_amount)

FROM fact_and_dim.fact_customer_daily_snapshot

GROUP BY

customer_key,

branch_key,

(date_key/100);
