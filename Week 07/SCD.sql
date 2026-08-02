CREATE TABLE fact_and_dim.dim_customer_scd0 (

    customer_key BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL UNIQUE,

    customer_no VARCHAR(50),

    nic_number VARCHAR(20),

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    date_of_birth DATE,

    registration_date DATE,

    gender VARCHAR(20)
);


CREATE TABLE fact_and_dim.dim_customer_scd1 (

    customer_key BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL UNIQUE,

    customer_no VARCHAR(50),

    nic_number VARCHAR(20),

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    gender VARCHAR(20),

    occupation VARCHAR(100),

    email VARCHAR(255),

    phone_number VARCHAR(30),

    city VARCHAR(100),

    state VARCHAR(100),

    postal_code VARCHAR(20),

    last_updated TIMESTAMP
);


CREATE TABLE fact_and_dim.dim_customer_scd2 (

    customer_key BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    customer_no VARCHAR(50),

    nic_number VARCHAR(20),

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    gender VARCHAR(20),

    occupation VARCHAR(100),

    email VARCHAR(255),

    phone_number VARCHAR(30),

    city VARCHAR(100),

    state VARCHAR(100),

    postal_code VARCHAR(20),

    effective_from DATE NOT NULL,

    effective_to DATE NOT NULL,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    version_number INT NOT NULL DEFAULT 1
);


CREATE TABLE fact_and_dim.dim_customer_scd3 (

    customer_key BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL UNIQUE,

    customer_no VARCHAR(50),

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    current_city VARCHAR(100),

    previous_city VARCHAR(100),

    current_occupation VARCHAR(100),

    previous_occupation VARCHAR(100),

    current_income_band VARCHAR(50),

    previous_income_band VARCHAR(50),

    last_updated TIMESTAMP
);



CREATE TABLE fact_and_dim.dim_customer_current (

    customer_key BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL UNIQUE,

    customer_no VARCHAR(50),

    nic_number VARCHAR(20),

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    gender VARCHAR(20),

    occupation VARCHAR(100),

    email VARCHAR(255),

    phone_number VARCHAR(30),

    city VARCHAR(100),

    state VARCHAR(100),

    postal_code VARCHAR(20),

    last_updated TIMESTAMP
);


CREATE TABLE fact_and_dim.dim_customer_history (

    history_key BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    customer_no VARCHAR(50),

    nic_number VARCHAR(20),

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    gender VARCHAR(20),

    occupation VARCHAR(100),

    email VARCHAR(255),

    phone_number VARCHAR(30),

    city VARCHAR(100),

    state VARCHAR(100),

    postal_code VARCHAR(20),

    effective_from DATE NOT NULL,

    effective_to DATE NOT NULL,

    change_reason VARCHAR(200),

    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);