-- ===========================================================
-- GOLD DIM CUSTOMER
-- SCD TYPE 2
-- ===========================================================


-- ===========================================================
-- STEP 1
-- Close existing current records when customer attributes
-- have changed.
-- ===========================================================

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


-- ===========================================================
-- STEP 2
-- Insert:
--
-- 1. Completely new customers
-- 2. New versions of customers whose previous version
--    was closed in STEP 1
-- ===========================================================

INSERT INTO gold.dim_customer
(
    customer_id,

    customer_no,
    nic_number,
    first_name,
    last_name,
    dob,
    gender,
    occupation,
    email,

    primary_address_line1,
    primary_address_line2,
    primary_city,
    primary_state,
    primary_postal_code,

    primary_phone_number,
    primary_phone_type,

    effective_from,
    effective_to,
    is_current,

    created_at,
    updated_at,

    source_system
)

SELECT
    source.customer_id,

    source.customer_no,
    source.nic_number,
    source.first_name,
    source.last_name,
    source.dob,
    source.gender,
    source.occupation,
    source.email,

    source.primary_address_line1,
    source.primary_address_line2,
    source.primary_city,
    source.primary_state,
    source.primary_postal_code,

    source.primary_phone_number,
    source.primary_phone_type,

    CURRENT_TIMESTAMP AS effective_from,

    TIMESTAMP '9999-12-31 23:59:59'
        AS effective_to,

    TRUE AS is_current,

    source.created_at,
    source.updated_at,

    source.source_system

FROM silver.customer_profile AS source

LEFT JOIN gold.dim_customer AS target

    ON target.customer_id = source.customer_id

    AND target.is_current = TRUE

WHERE target.customer_key IS NULL;