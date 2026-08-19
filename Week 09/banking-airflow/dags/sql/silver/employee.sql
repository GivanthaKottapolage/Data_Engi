WITH cleaned AS
(
    SELECT
        employee_id,
        TRIM(employee_no) AS employee_no,
        NULLIF(TRIM(name), '') AS name,
        NULLIF(TRIM(position), '') AS position,
        branch_id,

        created_at,
        updated_at,
        created_by,
        updated_by,
        load_timestamp,
        source_system,

        ROW_NUMBER() OVER
        (
            PARTITION BY employee_id
            ORDER BY
                updated_at DESC,
                created_at DESC,
                load_timestamp DESC
        ) AS rn

    FROM bronze.employee
)

SELECT
    employee_id,
    employee_no,
    name,
    position,
    branch_id,

    created_at,
    updated_at,
    created_by,
    updated_by,
    load_timestamp,
    source_system

FROM cleaned
WHERE rn = 1;