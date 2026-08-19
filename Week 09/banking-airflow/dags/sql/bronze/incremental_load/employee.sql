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
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.employee
WHERE
    created_at > '{{ last_watermark }}'
    OR updated_at > '{{ last_watermark }}';