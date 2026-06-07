# Zuu Crew Social Media Dataset

**Zero to Data Engineer — Week 01, Day 1 Exercise**

You have been given an export from a social media platform. Your job today is to load it into PostgreSQL, profile it, clean it, and query it.

---

## 1. What is in this folder

Seven CSV files. Each file is one table in the data model.

| File | What one row represents | Rows |
|------|------------------------|------|
| `users.csv` | One user account | 125,600 |
| `posts.csv` | One post written by a user | 220,400 |
| `comments.csv` | One comment on a post | 350,000 |
| `likes.csv` | One like on a post | 714,000 |
| `shares.csv` | One share of a post | 85,300 |
| `advertisements.csv` | One advert created by a user | 6,000 |
| `ad_clicks.csv` | One click on an advert | 164,800 |

**Total: ~1.66 million rows**

---

## 2. How the tables relate

Everything connects back to **users**.

- A **user** writes **posts** and creates **advertisements**
- Other users interact with posts by adding **comments**, **likes**, and **shares**
- Other users interact with adverts by recording **ad_clicks**

**Foreign keys at a glance:**

| Table | Foreign key column(s) | Points to |
|-------|-----------------------|-----------|
| posts | `user_id` | users |
| comments | `user_id`, `post_id` | users, posts |
| likes | `user_id`, `post_id` | users, posts |
| shares | `user_id`, `post_id` | users, posts |
| advertisements | `user_id` | users |
| ad_clicks | `user_id`, `ad_id` | users, advertisements |

---

## 3. Column reference

### users.csv
| Column | Type | Notes |
|--------|------|-------|
| `user_id` | integer | Primary key |
| `username` | text | User's handle |
| `email` | text | Contact email |
| `join_date` | text | When the account was created — mixed date formats |

### posts.csv
| Column | Type | Notes |
|--------|------|-------|
| `post_id` | integer | Primary key |
| `user_id` | integer | Author (→ users) |
| `content` | text | Body of the post |
| `created_at` | text | When it was written |

### comments.csv
| Column | Type | Notes |
|--------|------|-------|
| `comment_id` | integer | Primary key |
| `user_id` | integer | Author (→ users) |
| `post_id` | integer | The post it belongs to (→ posts) |
| `text` | text | Body of the comment |
| `created_at` | text | When it was written |

### likes.csv
| Column | Type | Notes |
|--------|------|-------|
| `like_id` | integer | Primary key |
| `user_id` | integer | Who liked (→ users) |
| `post_id` | integer | What was liked (→ posts) |
| `created_at` | text | When it happened |

### shares.csv
| Column | Type | Notes |
|--------|------|-------|
| `share_id` | integer | Primary key |
| `user_id` | integer | Who shared (→ users) |
| `post_id` | integer | What was shared (→ posts) |
| `created_at` | text | When it happened |

### advertisements.csv
| Column | Type | Notes |
|--------|------|-------|
| `ad_id` | integer | Primary key |
| `user_id` | integer | Advertiser (→ users) |
| `title` | text | Advert headline |
| `created_date` | text | When the advert went live |
| `cost` | text | Ad spend — **mixes numbers and text like "N/A". Watch this one.** |

### ad_clicks.csv
| Column | Type | Notes |
|--------|------|-------|
| `click_id` | integer | Primary key |
| `user_id` | integer | Who clicked (→ users) |
| `ad_id` | integer | Which advert (→ advertisements) |
| `clicked_at` | text | When the click happened |

---

## 4. About the data quality

**This data is intentionally dirty.** That is the exercise.

You will find:
- Missing values and blank strings
- Placeholder text (e.g. `"N/A"`, `"unknown"`)
- Duplicate rows
- Dates written in several different formats
- The `cost` column mixing numbers and text
- Foreign key rows pointing to parents that do not exist

Most user accounts are quiet — many never post, comment, share, or like anything. That is realistic social media behaviour, not a bug.

**Rule: profile first, decide on cleaning rules, then clean.**

---

## 5. Loading the CSVs into PostgreSQL via DataGrip

> **Before you start:** Make sure PostgreSQL is running and DataGrip shows a green **Successful** connection. If not, check the **Week 01 Prerequisites Setup Guide**.

---

### Step 1 — Create a schema

Open DataGrip. In the **Database Explorer** panel, right-click your `postgres` data source and choose **Open Query Console**. Run this:

```sql
CREATE SCHEMA IF NOT EXISTS social;
SET search_path TO social;
```

This creates a clean namespace called `social` to keep all your tables organised.

---

### Step 2 — Create the tables

Run the full SQL below in the Query Console. This creates all seven tables with the correct structure **before** you import any data.

> **Why TEXT for dates and cost?**  
> Date columns have mixed formats (e.g. `2024-01-15` vs `Jan 15 2024`), and `cost` contains both numbers and strings. Importing these as `TEXT` first prevents the importer from crashing or silently dropping rows. You will cast them to proper types after cleaning.

```sql
CREATE TABLE social.users (
    user_id    INTEGER PRIMARY KEY,
    username   TEXT,
    email      TEXT,
    join_date  TEXT
);

CREATE TABLE social.posts (
    post_id    INTEGER PRIMARY KEY,
    user_id    INTEGER,
    content    TEXT,
    created_at TEXT
);

CREATE TABLE social.comments (
    comment_id INTEGER PRIMARY KEY,
    user_id    INTEGER,
    post_id    INTEGER,
    text       TEXT,
    created_at TEXT
);

CREATE TABLE social.likes (
    like_id    INTEGER PRIMARY KEY,
    user_id    INTEGER,
    post_id    INTEGER,
    created_at TEXT
);

CREATE TABLE social.shares (
    share_id   INTEGER PRIMARY KEY,
    user_id    INTEGER,
    post_id    INTEGER,
    created_at TEXT
);

CREATE TABLE social.advertisements (
    ad_id        INTEGER PRIMARY KEY,
    user_id      INTEGER,
    title        TEXT,
    created_date TEXT,
    cost         TEXT
);

CREATE TABLE social.ad_clicks (
    click_id   INTEGER PRIMARY KEY,
    user_id    INTEGER,
    ad_id      INTEGER,
    clicked_at TEXT
);
```

---

### Step 3 — Import each CSV file

Import the files **in this exact order**. Parent tables (users, posts, advertisements) must be loaded before child tables that reference them.

| Order | CSV file | Target table |
|-------|----------|--------------|
| 1 | `users.csv` | `social.users` |
| 2 | `posts.csv` | `social.posts` |
| 3 | `advertisements.csv` | `social.advertisements` |
| 4 | `comments.csv` | `social.comments` |
| 5 | `likes.csv` | `social.likes` |
| 6 | `shares.csv` | `social.shares` |
| 7 | `ad_clicks.csv` | `social.ad_clicks` |

**For each file, do the following:**

1. In the **Database Explorer**, expand your connection → `postgres` → `social`
2. Right-click the target table and choose **Import Data from File…**
3. In the file picker, open the `Week 01/Dataset/` folder and select the CSV
4. In the **Import File** dialog, set these options:

   | Setting | Value |
   |---------|-------|
   | Format | CSV |
   | First row is header | ✅ Yes |
   | Separator | `,` (comma) |
   | Quote character | `"` (double quote) |
   | Encoding | UTF-8 |
   | Null value text | *(leave blank)* |
   | On error | Skip row |

5. Check the **column mapping** at the bottom — every CSV column should map to a table column. There should be no `<unmapped>` entries.
6. Click **Import** and wait for it to finish.
   - Small files (users, ads) finish in seconds
   - Large files (comments, likes, posts) may take 30–90 seconds
7. DataGrip will show: *"N rows imported, M rows skipped"* — note any skipped rows

**Repeat steps 1–7 for all seven files.**

---

### Step 4 — Verify the import

Run this in the Query Console to check row counts:

```sql
SELECT 'users'          AS table_name, COUNT(*) AS rows FROM social.users
UNION ALL
SELECT 'posts',                         COUNT(*)        FROM social.posts
UNION ALL
SELECT 'comments',                      COUNT(*)        FROM social.comments
UNION ALL
SELECT 'likes',                         COUNT(*)        FROM social.likes
UNION ALL
SELECT 'shares',                        COUNT(*)        FROM social.shares
UNION ALL
SELECT 'advertisements',                COUNT(*)        FROM social.advertisements
UNION ALL
SELECT 'ad_clicks',                     COUNT(*)        FROM social.ad_clicks
ORDER BY table_name;
```

Row counts in each CSV file:

| Table | Rows in CSV |
|-------|-------------|
| ad_clicks | 164,800 |
| advertisements | 6,000 |
| comments | 350,000 |
| likes | 714,000 |
| posts | 220,400 |
| shares | 85,300 |
| users | 125,600 |

**Your loaded counts may be lower than these — and that's expected.**

- If you imported every column as **`TEXT`** (the `social` schema in Step 2), the counts should match exactly.
- If you used the **typed schema** (e.g. `create_tables.sql`, which builds the `raw` tables with `TIMESTAMP` / `NUMERIC` / `NOT NULL` / `UNIQUE` / foreign keys), some rows are **rejected during import** because the data is intentionally dirty — bad dates, duplicate keys, missing required values. DataGrip reports *"N rows imported, M errors"* and saves the rejected rows to a `.txt` file (e.g. `users.txt`).
- **Those rejected rows are the dirty data.** Note how many were rejected per table and investigate them during profiling — don't try to force the totals to match.

---

### Troubleshooting

| Problem | Fix |
|---------|-----|
| DataGrip says **Connection refused** | PostgreSQL is not running. Windows: open Services → start PostgreSQL. macOS: open Postgres.app. Linux: `sudo service postgresql start` |
| DataGrip says **Password authentication failed** | Wrong password saved in DataGrip. Edit the data source and re-enter it. To reset the password: `sudo -u postgres psql` → `ALTER USER postgres PASSWORD 'newpassword';` |
| Rows are being skipped with type errors | A column type is wrong. Drop the table, change that column to `TEXT`, recreate it, and re-import |
| Import is very slow or hangs | Go to **Settings → Database → Import/Export** and increase *Batch size* to 5000 |
| You see `duplicate key` errors | The CSV has duplicate primary keys — this is intentional dirty data. Investigate as part of the cleaning exercise |
| Text looks garbled | Encoding issue. Change **Encoding** in the dialog from UTF-8 to `Windows-1252` |

---

## 6. What to do after loading

Once all seven tables are in PostgreSQL, start profiling:

1. **Count rows per table** — compare against the expected numbers above
2. **Count nulls per column** — especially `email`, `join_date`, `cost`, and all `created_at` fields
3. **Look for duplicates** — decide what a duplicate means for each table before deleting anything
4. **Check foreign keys** — not every child row will have a matching parent. Find the orphans
5. **Answer business questions** — which posts get the most engagement? How many users never posted anything? How much was spent on adverts that nobody clicked?

The cleaned tables will be the input for later weeks, when you automate this same pipeline with Airflow and load results into a cloud warehouse on AWS, GCP, and Azure.

---

*Zuu Crew — Machine Learning Academy*
