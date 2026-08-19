INSERT INTO gold.dim_date
(
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
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,

    d AS full_date,

    EXTRACT(DAY FROM d)::INTEGER AS day_of_month,

    EXTRACT(ISODOW FROM d)::INTEGER AS day_of_week,

    TRIM(TO_CHAR(d, 'Day')) AS day_name,

    EXTRACT(WEEK FROM d)::INTEGER AS week_of_year,

    EXTRACT(MONTH FROM d)::INTEGER AS month_number,

    TRIM(TO_CHAR(d, 'Month')) AS month_name,

    EXTRACT(QUARTER FROM d)::INTEGER AS quarter_number,

    EXTRACT(YEAR FROM d)::INTEGER AS year_number,

    EXTRACT(ISODOW FROM d) IN (6, 7) AS is_weekend

FROM generate_series(
    DATE '2020-01-01',
    DATE '2035-12-31',
    INTERVAL '1 day'
) AS dates(d)

ON CONFLICT (date_key)
DO NOTHING;