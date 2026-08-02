SELECT
    employee_id,
    employee_no,
    name,
    position,
    branch_id,
    CURRENT_TIMESTAMP AS load_timestamp,
    'CORE_BANKING' AS source_system
FROM core_banking.employee;