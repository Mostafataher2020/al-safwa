CREATE TABLE IF NOT EXISTS transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT, -- Add id as the primary key
  customer_id INTEGER NOT NULL,
  product_name TEXT,
  quantity INTEGER,
  unit_price REAL,
  payment_method TEXT,
  paid_amount REAL,
  is_payment INTEGER,
  balance_after_transaction REAL,
  date TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
);
