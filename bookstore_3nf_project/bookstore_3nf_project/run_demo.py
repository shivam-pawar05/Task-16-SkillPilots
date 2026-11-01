"""Runs the whole bookstore 3NF refactor and verifies referential integrity.
Usage:  python run_demo.py        (needs only Python 3, no installs)
"""
import sqlite3, pathlib

base = pathlib.Path(__file__).parent / "sql"
con = sqlite3.connect("bookstore.db")
con.execute("PRAGMA foreign_keys = ON")

for f in ["01_original_schema.sql", "02_refactor_3nf.sql", "03_verify_integrity.sql"]:
    con.executescript((base / f).read_text())
    print(f"[OK] ran {f}")
con.execute("PRAGMA foreign_keys = ON")

print("\n--- Books with authors, publisher ---")
for r in con.execute("""
    SELECT b.title, GROUP_CONCAT(a.name, ', '), p.name, p.city
    FROM books b JOIN publishers p USING(publisher_id)
    JOIN book_authors ba USING(book_id) JOIN authors a USING(author_id)
    GROUP BY b.book_id"""):
    print(r)

print("\n--- Sales ---")
for r in con.execute("""
    SELECT s.sale_id, b.title, c.name, s.sale_date, s.quantity
    FROM sales s JOIN books b USING(book_id) JOIN customers c USING(customer_id)"""):
    print(r)

print("\n--- Negative tests (each must be rejected) ---")
bad = [
 ("book with non-existent publisher", "INSERT INTO books VALUES (6,'X','111',10,999)"),
 ("sale for non-existent book",       "INSERT INTO sales (book_id,customer_id,sale_date,quantity) VALUES (999,1,'2026-10-30',1)"),
 ("book_author with bad author",      "INSERT INTO book_authors VALUES (1,999)"),
 ("delete publisher still in use",    "DELETE FROM publishers WHERE name='Addison-Wesley'"),
 ("sale with quantity 0",             "INSERT INTO sales (book_id,customer_id,sale_date,quantity) VALUES (1,1,'2026-10-30',0)"),
]
for label, sql in bad:
    try:
        con.execute(sql); print(f"[FAIL] {label}: was accepted!")
    except sqlite3.IntegrityError as e:
        print(f"[PASS] {label}: rejected ({e})")

print("\nPRAGMA foreign_key_check ->", con.execute("PRAGMA foreign_key_check").fetchall() or "no violations")
con.commit(); con.close()
