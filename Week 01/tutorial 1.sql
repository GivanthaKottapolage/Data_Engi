/*
===============================================================================
SECTION 0 - SQL FOR DATA ENGINEERING
===============================================================================

Question:
Why do we use multiple schemas?

Engineering Thinking:

Do not mix raw source data
with cleaned data and reporting tables.

Architecture

CSV Files
    ↓
raw
    ↓
sample_cde
    ↓
analytics
    ↓
Power BI / Tableau

raw
-----
Source data exactly as received.

sample_cde
----------
Cleaned and standardized data.

analytics
---------
Fact tables
Dimension tables
Views
Materialized Views

===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS sample_cde;
CREATE SCHEMA IF NOT EXISTS analytics;


/*
===============================================================================
SECTION 1 - TABLE DESIGN
===============================================================================

Question:
Why do we need constraints?

Engineering Thinking:

Database should protect data quality.

===============================================================================
*/

CREATE TABLE IF NOT EXISTS raw.users
(
    user_id     INTEGER PRIMARY KEY,
    username    VARCHAR(100) NOT NULL,
    email       VARCHAR(255) UNIQUE,
    join_date   DATE NOT NULL
);

/*
PRIMARY KEY

Uniquely identifies row.

-------------------------------------------------------------------------------

NOT NULL

Column cannot be empty.

-------------------------------------------------------------------------------

UNIQUE

No duplicate values allowed.

===============================================================================
*/



/*
===============================================================================
SECTION 2 - BASIC SQL
===============================================================================
*/

-- Show all users

SELECT *
FROM raw.users;

-- Select specific columns

SELECT
    username,
    email
FROM raw.users;

-- Filtering

SELECT *
FROM raw.users
WHERE join_date >= '2025-01-01';

-- Sorting

SELECT *
FROM raw.users
ORDER BY join_date DESC;

-- Limit

SELECT *
FROM raw.users
LIMIT 10;



/*
===============================================================================
SECTION 3 - AGGREGATIONS
===============================================================================
*/

SELECT COUNT(*)
FROM raw.users;

SELECT
    user_id,
    COUNT(*) total_posts
FROM raw.posts
GROUP BY user_id;

SELECT
    user_id,
    COUNT(*) total_posts
FROM raw.posts
GROUP BY user_id
HAVING COUNT(*) > 5;

/*
WHERE

Filters rows

HAVING

Filters groups

===============================================================================
*/




/*
===============================================================================
SECTION 4 - JOINS
===============================================================================
*/

-- INNER JOIN

SELECT
    u.username,
    p.post_id
FROM raw.users u
INNER JOIN raw.posts p
ON u.user_id = p.user_id;

-- LEFT JOIN

SELECT
    u.username,
    p.post_id
FROM raw.users u
LEFT JOIN raw.posts p
ON u.user_id = p.user_id;

-- RIGHT JOIN

SELECT
    u.username,
    p.post_id
FROM raw.users u
RIGHT JOIN raw.posts p
ON u.user_id = p.user_id;

-- FULL OUTER JOIN

SELECT *
FROM raw.users u
FULL OUTER JOIN raw.posts p
ON u.user_id = p.user_id;

-- SELF JOIN

SELECT
    a.username,
    b.username
FROM raw.users a
JOIN raw.users b
ON a.join_date = b.join_date
AND a.user_id <> b.user_id;



/*
===============================================================================
SECTION 5 - DATA QUALITY
===============================================================================
*/

SELECT *
FROM raw.users
WHERE email IS NULL;

SELECT
    email,
    COUNT(*)
FROM raw.users
GROUP BY email
HAVING COUNT(*) > 1;

SELECT c.*
FROM raw.comments c
LEFT JOIN raw.posts p
ON c.post_id = p.post_id
WHERE p.post_id IS NULL;

/*
Checks:

Missing Data

Duplicate Data

Referential Integrity

===============================================================================
*/



/*
===============================================================================
SECTION 6 - SUBQUERIES
===============================================================================
*/

SELECT *
FROM raw.posts
WHERE user_id =
(
    SELECT user_id
    FROM raw.users
    WHERE username='john'
);

SELECT *
FROM raw.users u
WHERE EXISTS
(
    SELECT 1
    FROM raw.posts p
    WHERE p.user_id = u.user_id
);

SELECT *
FROM raw.users
WHERE user_id IN
(
    SELECT user_id
    FROM raw.posts
);



/*
===============================================================================
SECTION 7 - CTE
===============================================================================
*/

WITH post_counts AS
(
    SELECT
        user_id,
        COUNT(*) total_posts
    FROM raw.posts
    GROUP BY user_id
)
SELECT *
FROM post_counts;

/*
CTE

Common Table Expression

Temporary result set

Improves readability

===============================================================================
*/



/*
===============================================================================
SECTION 8 - VIEWS
===============================================================================
*/

CREATE OR REPLACE VIEW analytics.v_user_post_summary AS
SELECT
    u.user_id,
    u.username,
    COUNT(p.post_id) total_posts
FROM raw.users u
LEFT JOIN raw.posts p
ON u.user_id = p.user_id
GROUP BY
    u.user_id,
    u.username;

SELECT *
FROM analytics.v_user_post_summary;

/*
View stores SQL

Does not store data

===============================================================================
*/



/*
===============================================================================
SECTION 9 - MATERIALIZED VIEWS
===============================================================================
*/

CREATE MATERIALIZED VIEW analytics.mv_user_post_summary AS
SELECT
    u.user_id,
    u.username,
    COUNT(p.post_id) total_posts
FROM raw.users u
LEFT JOIN raw.posts p
ON u.user_id = p.user_id
GROUP BY
    u.user_id,
    u.username;

REFRESH MATERIALIZED VIEW analytics.mv_user_post_summary;

/*
Stores result

Fast reads

Needs refresh

===============================================================================
*/



/*
===============================================================================
SECTION 10 - WINDOW FUNCTIONS
===============================================================================
*/

SELECT
    user_id,
    COUNT(*) total_posts,
    RANK() OVER
    (
        ORDER BY COUNT(*) DESC
    ) ranking
FROM raw.posts
GROUP BY user_id;

SELECT
    user_id,
    ROW_NUMBER() OVER
    (
        ORDER BY user_id
    )
FROM raw.users;




/*
===============================================================================
SECTION 11 - TRANSACTIONS
===============================================================================
*/

BEGIN;

INSERT INTO raw.posts
(
    post_id,
    user_id,
    content,
    created_at
)
VALUES
(
    1001,
    1,
    'Transaction Demo',
    NOW()
);

COMMIT;

/*
ACID

Atomicity
Consistency
Isolation
Durability

===============================================================================
*/



/*
===============================================================================
SECTION 12 - EXPLAIN ANALYZE
===============================================================================
*/

EXPLAIN ANALYZE
SELECT *
FROM raw.posts
WHERE user_id = 10;

/*
Never Guess

Measure

Look For

Seq Scan

Index Scan

Execution Time

===============================================================================
*/



/*
===============================================================================
SECTION 13 - INDEXES
===============================================================================
*/

CREATE INDEX IF NOT EXISTS idx_posts_user
ON raw.posts(user_id);

EXPLAIN ANALYZE
SELECT *
FROM raw.posts
WHERE user_id = 10;

/*
Benefits

Faster Reads

Costs

Slower Inserts
Slower Updates
More Storage

===============================================================================
*/


/*
===============================================================================
SECTION 14 - WHAT HAPPENS INTERNALLY?
===============================================================================

INSERT

1. Write table row
2. Update indexes
3. Write WAL
4. Commit

-------------------------------------------------------------------------------

UPDATE

1. Create new row version
2. Mark old row dead
3. Update indexes

-------------------------------------------------------------------------------

DELETE

1. Mark row dead
2. Update indexes
3. VACUUM cleans later

===============================================================================
*/


/*
===============================================================================
SECTION 15 - VACUUM
===============================================================================
*/

VACUUM ANALYZE raw.posts;

/*
VACUUM

Removes dead tuples

ANALYZE

Updates optimizer statistics

===============================================================================
*/



/*
===============================================================================
SECTION 16 - CLUSTER
===============================================================================
*/

CREATE INDEX IF NOT EXISTS idx_cluster_posts
ON raw.posts(user_id);

CLUSTER raw.posts
USING idx_cluster_posts;

/*
Index helps FIND rows

Cluster helps STORE rows together

===============================================================================
*/




/*
===============================================================================
SECTION 17 - PARTITIONING
===============================================================================
*/

CREATE TABLE raw.posts_partitioned
(
    post_id INT,
    user_id INT,
    created_at DATE
)
PARTITION BY RANGE(created_at);

CREATE TABLE raw.posts_2025_01
PARTITION OF raw.posts_partitioned
FOR VALUES FROM ('2025-01-01')
TO ('2025-02-01');

/*
Partition Pruning

Only relevant partitions scanned

===============================================================================
*/



/*
===============================================================================
SECTION 18 - STAR SCHEMA
===============================================================================

OLTP

users
posts
comments

-------------------------------------------------------------------------------

Analytics

dim_user
dim_date
fact_post_engagement

-------------------------------------------------------------------------------

Benefits

Simpler reporting
Fewer joins
Better BI performance

===============================================================================
*/



/*
===============================================================================
SECTION 19 - REPORTING
===============================================================================
*/

SELECT
    u.username,
    COUNT(*) total_posts
FROM raw.users u
JOIN raw.posts p
ON u.user_id = p.user_id
GROUP BY u.username
ORDER BY total_posts DESC
LIMIT 10;

SELECT
    DATE_TRUNC('month', join_date) month,
    COUNT(*) users_joined
FROM raw.users
GROUP BY DATE_TRUNC('month', join_date)
ORDER BY month;

/*
Executive KPI Example
*/

SELECT
    (SELECT COUNT(*) FROM raw.users) total_users,
    (SELECT COUNT(*) FROM raw.posts) total_posts,
    (SELECT COUNT(*) FROM raw.comments) total_comments,
    (SELECT COUNT(*) FROM raw.likes) total_likes,
    (SELECT COUNT(*) FROM raw.shares) total_shares;