CREATE SCHEMA IF NOT EXISTS gold;


-- gold.dim_customer — SCD Type 2
CREATE TABLE IF NOT EXISTS gold.dim_customer
(
    customer_key BIGINT GENERATED ALWAYS AS IDENTITY,
    customer_id BIGINT NOT NULL,

    customer_no VARCHAR(50),
    nic_number VARCHAR(20),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    dob DATE,
    gender VARCHAR(20),
    occupation VARCHAR(100),
    email VARCHAR(255),

    primary_address_line1 VARCHAR(255),
    primary_address_line2 VARCHAR(255),
    primary_city VARCHAR(100),
    primary_state VARCHAR(100),
    primary_postal_code VARCHAR(20),

    primary_phone_number VARCHAR(30),
    primary_phone_type VARCHAR(20),

    effective_from TIMESTAMP NOT NULL,
    effective_to TIMESTAMP NOT NULL,
    is_current BOOLEAN NOT NULL,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    source_system VARCHAR(50),

    CONSTRAINT pk_dim_customer
        PRIMARY KEY (customer_key)
);

-- gold.dim_branch — SCD Type 1

CREATE TABLE IF NOT EXISTS gold.dim_branch
(
    branch_key BIGINT GENERATED ALWAYS AS IDENTITY,
    branch_id BIGINT NOT NULL,

    branch_code VARCHAR(20),
    name VARCHAR(255),
    address VARCHAR(500),
    ifsc_code VARCHAR(20),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    source_system VARCHAR(50),

    CONSTRAINT pk_dim_branch
        PRIMARY KEY (branch_key),

    CONSTRAINT uq_dim_branch_branch_id
        UNIQUE (branch_id)
);

-- gold.dim_employee — SCD Type 2

CREATE TABLE IF NOT EXISTS gold.dim_employee
(
    employee_key BIGINT GENERATED ALWAYS AS IDENTITY,
    employee_id BIGINT NOT NULL,

    employee_no VARCHAR(50),
    name VARCHAR(255),
    position VARCHAR(100),
    branch_id BIGINT,

    effective_from TIMESTAMP NOT NULL,
    effective_to TIMESTAMP NOT NULL,
    is_current BOOLEAN NOT NULL,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    source_system VARCHAR(50),

    CONSTRAINT pk_dim_employee
        PRIMARY KEY (employee_key)
);

-- gold.dim_account — SCD Type 2

CREATE TABLE IF NOT EXISTS gold.dim_account
(
    account_key BIGINT GENERATED ALWAYS AS IDENTITY,
    account_id BIGINT NOT NULL,

    account_number VARCHAR(50),
    opening_date DATE,
    status VARCHAR(30),
    branch_id BIGINT,
    account_type VARCHAR(50),

    effective_from TIMESTAMP NOT NULL,
    effective_to TIMESTAMP NOT NULL,
    is_current BOOLEAN NOT NULL,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    source_system VARCHAR(50),

    CONSTRAINT pk_dim_account
        PRIMARY KEY (account_key)
);

-- gold.dim_loan — SCD Type 2

CREATE TABLE IF NOT EXISTS gold.dim_loan
(
    loan_key BIGINT GENERATED ALWAYS AS IDENTITY,
    loan_id BIGINT NOT NULL,

    loan_number VARCHAR(50),
    customer_id BIGINT,
    loan_type VARCHAR(50),
    start_date DATE,

    interest_rate DECIMAL(8,4),

    effective_from TIMESTAMP NOT NULL,
    effective_to TIMESTAMP NOT NULL,
    is_current BOOLEAN NOT NULL,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    source_system VARCHAR(50),

    CONSTRAINT pk_dim_loan
        PRIMARY KEY (loan_key)
);

-- gold.dim_card — SCD Type 2

CREATE TABLE IF NOT EXISTS gold.dim_card
(
    card_key BIGINT GENERATED ALWAYS AS IDENTITY,
    card_id BIGINT NOT NULL,

    card_number VARCHAR(30),
    account_id BIGINT,
    card_type VARCHAR(30),
    expiry_date DATE,
    status VARCHAR(30),

    effective_from TIMESTAMP NOT NULL,
    effective_to TIMESTAMP NOT NULL,
    is_current BOOLEAN NOT NULL,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    source_system VARCHAR(50),

    CONSTRAINT pk_dim_card
        PRIMARY KEY (card_key)
);

-- gold.dim_atm — SCD Type 1

CREATE TABLE IF NOT EXISTS gold.dim_atm
(
    atm_key BIGINT GENERATED ALWAYS AS IDENTITY,
    atm_id BIGINT NOT NULL,

    atm_code VARCHAR(30),
    branch_id BIGINT,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    source_system VARCHAR(50),

    CONSTRAINT pk_dim_atm
        PRIMARY KEY (atm_key),

    CONSTRAINT uq_dim_atm_atm_id
        UNIQUE (atm_id)
);

--gold.dim_merchant — SCD Type 1

CREATE TABLE IF NOT EXISTS gold.dim_merchant
(
    merchant_key BIGINT GENERATED ALWAYS AS IDENTITY,
    merchant_id BIGINT NOT NULL,

    merchant_name VARCHAR(255),
    category VARCHAR(100),

    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    source_system VARCHAR(50),

    CONSTRAINT pk_dim_merchant
        PRIMARY KEY (merchant_key),

    CONSTRAINT uq_dim_merchant_merchant_id
        UNIQUE (merchant_id)
);

--gold.dim_date — Static Dimension

CREATE TABLE IF NOT EXISTS gold.dim_date
(
    date_key INTEGER NOT NULL,
    full_date DATE NOT NULL,

    day_of_month INTEGER,
    day_of_week INTEGER,
    day_name VARCHAR(20),

    week_of_year INTEGER,
    month_number INTEGER,
    month_name VARCHAR(20),

    quarter_number INTEGER,
    year_number INTEGER,

    is_weekend BOOLEAN,

    CONSTRAINT pk_dim_date
        PRIMARY KEY (date_key),

    CONSTRAINT uq_dim_date_full_date
        UNIQUE (full_date)
);



UPDATE gold.dim_customer AS target

SET
    effective_to = CURRENT_TIMESTAMP,
    is_current = FALSE,
    updated_at = CURRENT_TIMESTAMP

FROM silver.customer_profile AS source

WHERE target.customer_id = source.customer_id

  AND target.is_current = TRUE

  AND
  (
       target.customer_no IS DISTINCT FROM source.customer_no
    OR target.nic_number IS DISTINCT FROM source.nic_number
    OR target.first_name IS DISTINCT FROM source.first_name
    OR target.last_name IS DISTINCT FROM source.last_name
    OR target.dob IS DISTINCT FROM source.dob
    OR target.gender IS DISTINCT FROM source.gender
    OR target.occupation IS DISTINCT FROM source.occupation
    OR target.email IS DISTINCT FROM source.email

    OR target.primary_address_line1
       IS DISTINCT FROM source.primary_address_line1

    OR target.primary_address_line2
       IS DISTINCT FROM source.primary_address_line2

    OR target.primary_city
       IS DISTINCT FROM source.primary_city

    OR target.primary_state
       IS DISTINCT FROM source.primary_state

    OR target.primary_postal_code
       IS DISTINCT FROM source.primary_postal_code

    OR target.primary_phone_number
       IS DISTINCT FROM source.primary_phone_number

    OR target.primary_phone_type
       IS DISTINCT FROM source.primary_phone_type
  );



INSERT INTO gold.dim_date (
    date_key,
    full_date,
    day_of_month,
    day_of_week,
    day_name,
    week_of_year,
    month_number,
    month_name,
    quarter_number,
    year_number,
    is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER                    AS date_key,
    d::DATE                                            AS full_date,
    EXTRACT(DAY FROM d)::INTEGER                       AS day_of_month,
    EXTRACT(ISODOW FROM d)::INTEGER                    AS day_of_week,   -- 1 = Monday … 7 = Sunday
    TO_CHAR(d, 'FMDay')                                AS day_name,
    EXTRACT(WEEK FROM d)::INTEGER                      AS week_of_year,
    EXTRACT(MONTH FROM d)::INTEGER                     AS month_number,
    TO_CHAR(d, 'FMMonth')                              AS month_name,
    EXTRACT(QUARTER FROM d)::INTEGER                   AS quarter_number,
    EXTRACT(YEAR FROM d)::INTEGER                      AS year_number,
    (EXTRACT(ISODOW FROM d) IN (6, 7))                 AS is_weekend
FROM generate_series(
    '2015-01-01'::DATE,
    '2030-12-31'::DATE,
    '1 day'::INTERVAL
) AS d
ON CONFLICT (date_key) DO NOTHING;