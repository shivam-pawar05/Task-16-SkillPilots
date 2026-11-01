-- STEP 0: Original (unnormalized) bookstore table.
-- Problems: repeating groups (author1/author2, sale1/sale2),
-- publisher_city depends on publisher_name (transitive dependency),
-- customer data repeated inside every row.
DROP TABLE IF EXISTS bookstore_flat;
CREATE TABLE bookstore_flat (
    book_id         INTEGER,
    title           TEXT,
    isbn            TEXT,
    price           REAL,
    publisher_name  TEXT,
    publisher_city  TEXT,
    author1         TEXT,
    author2         TEXT,
    sale1_customer  TEXT,
    sale1_date      TEXT,
    sale1_qty       INTEGER,
    sale2_customer  TEXT,
    sale2_date      TEXT,
    sale2_qty       INTEGER
);

INSERT INTO bookstore_flat VALUES
(1,'The Pragmatic Programmer','9780135957059',42.50,'Addison-Wesley','Boston','Andrew Hunt','David Thomas','Riya Sharma','2026-09-01',2,'Amit Patel','2026-09-10',1),
(2,'Clean Code','9780132350884',38.00,'Prentice Hall','New Jersey','Robert C. Martin',NULL,'Amit Patel','2026-09-05',1,NULL,NULL,NULL),
(3,'Refactoring','9780134757599',45.00,'Addison-Wesley','Boston','Martin Fowler',NULL,'Neha Kulkarni','2026-09-12',3,'Riya Sharma','2026-09-20',1),
(4,'Design Patterns','9780201633610',55.00,'Addison-Wesley','Boston','Erich Gamma','Richard Helm','Neha Kulkarni','2026-10-02',1,NULL,NULL,NULL);
