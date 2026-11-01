-- STEP 4: Verify referential integrity with sample inserts.
PRAGMA foreign_keys = ON;

-- Valid inserts (should succeed)
INSERT INTO publishers (name, city) VALUES ('O''Reilly', 'Sebastopol');
INSERT INTO authors (name) VALUES ('Kathy Sierra');
INSERT INTO books (book_id, title, isbn, price, publisher_id)
    VALUES (5, 'Head First Java', '9780596009205', 49.00,
            (SELECT publisher_id FROM publishers WHERE name = 'O''Reilly'));
INSERT INTO book_authors (book_id, author_id)
    VALUES (5, (SELECT author_id FROM authors WHERE name = 'Kathy Sierra'));
INSERT INTO sales (book_id, customer_id, sale_date, quantity)
    VALUES (5, 1, '2026-10-30', 2);

-- Invalid inserts (each should FAIL with "FOREIGN KEY constraint failed").
-- Uncomment one at a time to test manually; run_demo.py tests them automatically.
-- INSERT INTO books (book_id,title,isbn,price,publisher_id) VALUES (6,'X','111',10,999);
-- INSERT INTO sales (book_id,customer_id,sale_date,quantity) VALUES (999,1,'2026-10-30',1);
-- INSERT INTO book_authors (book_id,author_id) VALUES (1,999);
-- DELETE FROM publishers WHERE name = 'Addison-Wesley';  -- blocked: books reference it
