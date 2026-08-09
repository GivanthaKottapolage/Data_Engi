WITH cleaned AS
(
    SELECT
        branch_id,
        TRIM(branch_code) AS branch_code,
        NULLIF(TRIM(name), '') AS name,
        NULLIF(TRIM(address), '') AS address,
        NULLIF(TRIM(ifsc_code), '') AS ifsc_code,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY branch_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.branch
)

SELECT
    branch_id,
    branch_code,
    name,
    address,
    ifsc_code,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;