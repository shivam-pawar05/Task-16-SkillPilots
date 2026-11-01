-- STEPS 1-3: Normalize to 3NF and add primary/foreign keys.
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS publishers;

-- STEP 1 + 2: separate tables, each with a primary key
CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT NOT NULL UNIQUE,
    city         TEXT
);
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name      TEXT NOT NULL UNIQUE
);
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL UNIQUE
);

-- STEP 3: foreign keys
CREATE TABLE books (
    book_id      INTEGER PRIMARY KEY,
    title        TEXT NOT NULL,
    isbn         TEXT NOT NULL UNIQUE,
    price        REAL NOT NULL CHECK (price >= 0),
    publisher_id INTEGER NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);
-- many-to-many: a book can have many authors, an author many books
CREATE TABLE book_authors (
    book_id   INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id)   REFERENCES books(book_id)     ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE RESTRICT
);
CREATE TABLE sales (
    sale_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id     INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    sale_date   TEXT NOT NULL,
    quantity    INTEGER NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (book_id)     REFERENCES books(book_id)         ON DELETE RESTRICT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT
);

-- Migrate data from the flat table
INSERT INTO publishers (name, city)
    SELECT DISTINCT publisher_name, publisher_city FROM bookstore_flat;

INSERT INTO authors (name)
    SELECT author1 FROM bookstore_flat WHERE author1 IS NOT NULL
    UNION
    SELECT author2 FROM bookstore_flat WHERE author2 IS NOT NULL;

INSERT INTO customers (name)
    SELECT sale1_customer FROM bookstore_flat WHERE sale1_customer IS NOT NULL
    UNION
    SELECT sale2_customer FROM bookstore_flat WHERE sale2_customer IS NOT NULL;

INSERT INTO books (book_id, title, isbn, price, publisher_id)
    SELECT f.book_id, f.title, f.isbn, f.price, p.publisher_id
    FROM bookstore_flat f JOIN publishers p ON p.name = f.publisher_name;

INSERT INTO book_authors (book_id, author_id)
    SELECT f.book_id, a.author_id FROM bookstore_flat f JOIN authors a ON a.name = f.author1
    UNION
    SELECT f.book_id, a.author_id FROM bookstore_flat f JOIN authors a ON a.name = f.author2;

INSERT INTO sales (book_id, customer_id, sale_date, quantity)
    SELECT f.book_id, c.customer_id, f.sale1_date, f.sale1_qty
    FROM bookstore_flat f JOIN customers c ON c.name = f.sale1_customer
    WHERE f.sale1_qty IS NOT NULL
    UNION ALL
    SELECT f.book_id, c.customer_id, f.sale2_date, f.sale2_qty
    FROM bookstore_flat f JOIN customers c ON c.name = f.sale2_customer
    WHERE f.sale2_qty IS NOT NULL;
