WITH cleaned AS
(
    SELECT
        atm_id,
        TRIM(atm_code) AS atm_code,
        branch_id,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY atm_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.atm
)

SELECT
    atm_id,
    atm_code,
    branch_id,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;