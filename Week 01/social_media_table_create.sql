-- =====================================================
-- Create Schema
-- =====================================================

CREATE SCHEMA IF NOT EXISTS raw;

-- =====================================================
-- Users
-- =====================================================

CREATE TABLE IF NOT EXISTS raw.users (
    user_id     INTEGER PRIMARY KEY,
    username    VARCHAR(100),
    email       VARCHAR(255),
    join_date   TIMESTAMP
);

-- =====================================================
-- Posts
-- =====================================================

CREATE TABLE IF NOT EXISTS raw.posts (
    post_id      INTEGER PRIMARY KEY,
    user_id      INTEGER,
    content      TEXT,
    created_at   TIMESTAMP,

    CONSTRAINT fk_posts_user
        FOREIGN KEY (user_id)
        REFERENCES raw.users(user_id)
);

-- =====================================================
-- Comments
-- =====================================================

CREATE TABLE IF NOT EXISTS raw.comments (
    comment_id    INTEGER PRIMARY KEY,
    post_id       INTEGER,
    user_id       INTEGER,
    text          TEXT,
    created_at    TIMESTAMP,

    CONSTRAINT fk_comments_post
        FOREIGN KEY (post_id)
        REFERENCES raw.posts(post_id),

    CONSTRAINT fk_comments_user
        FOREIGN KEY (user_id)
        REFERENCES raw.users(user_id)
);

-- =====================================================
-- Likes
-- =====================================================

CREATE TABLE IF NOT EXISTS raw.likes (
    like_id       INTEGER PRIMARY KEY,
    post_id       INTEGER,
    user_id       INTEGER,
    created_at    TIMESTAMP,

    CONSTRAINT fk_likes_post
        FOREIGN KEY (post_id)
        REFERENCES raw.posts(post_id),

    CONSTRAINT fk_likes_user
        FOREIGN KEY (user_id)
        REFERENCES raw.users(user_id)
);

-- =====================================================
-- Shares
-- =====================================================

CREATE TABLE IF NOT EXISTS raw.shares (
    share_id      INTEGER PRIMARY KEY,
    post_id       INTEGER,
    user_id       INTEGER,
    created_at    TIMESTAMP,

    CONSTRAINT fk_shares_post
        FOREIGN KEY (post_id)
        REFERENCES raw.posts(post_id),

    CONSTRAINT fk_shares_user
        FOREIGN KEY (user_id)
        REFERENCES raw.users(user_id)
);

-- =====================================================
-- Advertisements
-- =====================================================

CREATE TABLE IF NOT EXISTS raw.advertisements (
    ad_id         INTEGER PRIMARY KEY,
    user_id       INTEGER,
    title         VARCHAR(255),
    create_date   TIMESTAMP,
    cost          NUMERIC(10,2),

    CONSTRAINT fk_ads_user
        FOREIGN KEY (user_id)
        REFERENCES raw.users(user_id)
);

-- =====================================================
-- Ad Clicks
-- =====================================================

CREATE TABLE IF NOT EXISTS raw.ad_clicks (
    click_id      INTEGER PRIMARY KEY,
    ad_id         INTEGER,
    user_id       INTEGER,
    clicked_at    TIMESTAMP,

    CONSTRAINT fk_clicks_ad
        FOREIGN KEY (ad_id)
        REFERENCES raw.advertisements(ad_id),

    CONSTRAINT fk_clicks_user
        FOREIGN KEY (user_id)
        REFERENCES raw.users(user_id)
);


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'raw'
ORDER BY table_name;

select * from raw.comments limit 10;

SELECT 'users' AS table_name, COUNT(*) FROM raw.users
UNION ALL
SELECT 'posts', COUNT(*) FROM raw.posts
UNION ALL
SELECT 'comments', COUNT(*) FROM raw.comments
UNION ALL
SELECT 'likes', COUNT(*) FROM raw.likes
UNION ALL
SELECT 'shares', COUNT(*) FROM raw.shares
UNION ALL
SELECT 'advertisements', COUNT(*) FROM raw.advertisements
UNION ALL
SELECT 'ad_clicks', COUNT(*) FROM raw.ad_clicks;