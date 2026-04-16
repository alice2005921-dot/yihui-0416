PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS stock_moves;
DROP TABLE IF EXISTS approval_logs;
DROP TABLE IF EXISTS issue_request_items;
DROP TABLE IF EXISTS issue_requests;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
  department_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE users (
  user_id INTEGER PRIMARY KEY,
  department_id INTEGER NOT NULL REFERENCES departments (department_id),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL CHECK (role IN ('EMPLOYEE', 'MANAGER', 'WAREHOUSE', 'ADMIN'))
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  unit_cost INTEGER NOT NULL CHECK (unit_cost >= 0),
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

CREATE TABLE issue_requests (
  request_id INTEGER PRIMARY KEY,
  requester_id INTEGER NOT NULL REFERENCES users (user_id),
  department_id INTEGER NOT NULL REFERENCES departments (department_id),
  status TEXT NOT NULL CHECK (status IN ('DRAFT','PENDING_APPROVAL','APPROVED','REJECTED','FULFILLED','CANCELLED')),
  reason TEXT NOT NULL,
  needed_date TEXT,
  created_at TEXT NOT NULL
);

CREATE TABLE issue_request_items (
  request_item_id INTEGER PRIMARY KEY,
  request_id INTEGER NOT NULL REFERENCES issue_requests (request_id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products (product_id),
  qty INTEGER NOT NULL CHECK (qty > 0)
);

CREATE TABLE approval_logs (
  approval_log_id INTEGER PRIMARY KEY,
  request_id INTEGER NOT NULL REFERENCES issue_requests (request_id) ON DELETE CASCADE,
  approver_id INTEGER NOT NULL REFERENCES users (user_id),
  action TEXT NOT NULL CHECK (action IN ('APPROVE','REJECT')),
  comment TEXT,
  acted_at TEXT NOT NULL
);

CREATE TABLE stock_moves (
  stock_move_id INTEGER PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products (product_id),
  request_id INTEGER REFERENCES issue_requests (request_id),
  move_type TEXT NOT NULL CHECK (move_type IN ('IN','OUT','ADJUST','REVERSE')),
  qty INTEGER NOT NULL,
  moved_at TEXT NOT NULL,
  ref TEXT
);

-- 範例資料
INSERT INTO departments (department_id, name) VALUES
  (1, '行政部'),
  (2, '資訊部'),
  (3, '設計部');

INSERT INTO users (user_id, department_id, name, email, role) VALUES
  (1, 1, '王小美', 'amy@example.com', 'EMPLOYEE'),
  (2, 1, '陳主管', 'manager_admin@example.com', 'MANAGER'),
  (3, 2, '李工程師', 'it@example.com', 'EMPLOYEE'),
  (4, 2, '林主管', 'manager_it@example.com', 'MANAGER'),
  (5, 3, '張設計', 'design@example.com', 'EMPLOYEE'),
  (6, 2, '倉管阿明', 'wh@example.com', 'WAREHOUSE');

INSERT INTO products (product_id, sku, name, category, unit_cost, is_active) VALUES
  (1, 'MS-010', '無線滑鼠', '周邊', 690, 1),
  (2, 'KB-001', '機械鍵盤 87 鍵', '周邊', 1890, 1),
  (3, 'HB-200', 'USB Hub 8 埠', '周邊', 980, 1),
  (4, 'CM-110', '螢幕 27 吋', '設備', 6990, 1);

-- 入庫
INSERT INTO stock_moves (stock_move_id, product_id, request_id, move_type, qty, moved_at, ref) VALUES
  (1, 1, NULL, 'IN', 30, '2026-03-01', '初始入庫'),
  (2, 2, NULL, 'IN', 12, '2026-03-01', '初始入庫'),
  (3, 3, NULL, 'IN', 18, '2026-03-01', '初始入庫'),
  (4, 4, NULL, 'IN', 6,  '2026-03-01', '初始入庫');

-- 申請單
INSERT INTO issue_requests (request_id, requester_id, department_id, status, reason, needed_date, created_at) VALUES
  (1001, 1, 1, 'FULFILLED', '行政部新進同仁設備', '2026-03-05', '2026-03-02'),
  (1002, 3, 2, 'APPROVED',  '資訊部測試環境耗材', '2026-03-10', '2026-03-06'),
  (1003, 5, 3, 'REJECTED',  '設計部外接設備需求', '2026-03-12', '2026-03-07');

INSERT INTO issue_request_items (request_item_id, request_id, product_id, qty) VALUES
  (1, 1001, 1, 3),
  (2, 1001, 2, 2),
  (3, 1002, 3, 4),
  (4, 1003, 4, 2);

-- 簽核紀錄
INSERT INTO approval_logs (approval_log_id, request_id, approver_id, action, comment, acted_at) VALUES
  (1, 1001, 2, 'APPROVE', 'OK', '2026-03-03'),
  (2, 1002, 4, 'APPROVE', '請倉管安排出庫', '2026-03-07'),
  (3, 1003, 2, 'REJECT', '請補用途與預算', '2026-03-08');

-- 出庫（只針對已 fulfilled 的 1001）
INSERT INTO stock_moves (stock_move_id, product_id, request_id, move_type, qty, moved_at, ref) VALUES
  (11, 1, 1001, 'OUT', -3, '2026-03-04', '領用單#1001'),
  (12, 2, 1001, 'OUT', -2, '2026-03-04', '領用單#1001');

