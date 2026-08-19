SELECT
    c.customer_id,
    c.customer_no,
    c.nic_number,
    c.first_name,
    c.last_name,
    c.dob,
    c.gender,
    c.occupation,
    c.email,

    a.address_line1 AS primary_address_line1,
    a.address_line2 AS primary_address_line2,
    a.city AS primary_city,
    a.state AS primary_state,
    a.postal_code AS primary_postal_code,

    p.phone_number AS primary_phone_number,
    p.phone_type AS primary_phone_type,

    c.created_at,
    c.updated_at,
    c.created_by,
    c.updated_by,

    CURRENT_TIMESTAMP AS load_timestamp,
    c.source_system

FROM silver.customer c

LEFT JOIN LATERAL
(
    SELECT
        address_line1,
        address_line2,
        city,
        state,
        postal_code

    FROM silver.customer_address ca

    WHERE ca.customer_id = c.customer_id

    ORDER BY
        CASE
            WHEN ca.is_primary = TRUE THEN 1
            ELSE 2
        END,
        ca.updated_at DESC,
        ca.created_at DESC,
        ca.load_timestamp DESC

    LIMIT 1

) a ON TRUE

LEFT JOIN LATERAL
(
    SELECT
        phone_number,
        phone_type

    FROM silver.customer_phone cp

    WHERE cp.customer_id = c.customer_id

    ORDER BY
        CASE
            WHEN cp.is_primary = TRUE THEN 1
            ELSE 2
        END,
        cp.updated_at DESC,
        cp.created_at DESC,
        cp.load_timestamp DESC

    LIMIT 1

) p ON TRUE;