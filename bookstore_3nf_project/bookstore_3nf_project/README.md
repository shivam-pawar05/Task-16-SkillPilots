# Bookstore Database Refactor to 3NF with Foreign Keys

## Task
Refactor the bookstore database to 3NF and add foreign key relationships.

## Run
    python run_demo.py        # Python 3 only; creates bookstore.db
Or manually: `sqlite3 bookstore.db < sql/01_original_schema.sql`, then 02, then 03.

## Steps mapped to files
| Step | What | Where |
|---|---|---|
| 0 | Original flat table (repeating groups) | sql/01_original_schema.sql |
| 1 | Identify repeating groups -> separate tables (authors, customers, sales, publishers) | sql/02_refactor_3nf.sql |
| 2 | Primary keys for each new table | sql/02_refactor_3nf.sql |
| 3 | Foreign keys: books->publishers, book_authors->books/authors, sales->books/customers | sql/02_refactor_3nf.sql |
| 4 | Verify referential integrity with sample inserts | sql/03_verify_integrity.sql + run_demo.py |

## Normal forms
- 1NF: author1/author2 and sale1_*/sale2_* repeating groups removed (rows per author / per sale).
- 2NF: every non-key column depends on the whole key (book_authors has no extra columns).
- 3NF: publisher_city depended on publisher_name, not book_id -> moved to `publishers`.

## ER summary
publishers 1--N books N--M authors (via book_authors)
books 1--N sales N--1 customers
