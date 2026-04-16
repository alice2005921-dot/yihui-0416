PRAGMA foreign_keys = ON;

-- =========================
-- 小型資料模型（採購/庫存）
-- =========================

DROP TABLE IF EXISTS purchase_items;
DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS stock_moves;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;

CREATE TABLE suppliers (
  supplier_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  contact_email TEXT
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  unit_cost INTEGER NOT NULL CHECK (unit_cost >= 0), -- 以「元」存整數
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

CREATE TABLE purchases (
  purchase_id INTEGER PRIMARY KEY,
  supplier_id INTEGER NOT NULL REFERENCES suppliers (supplier_id),
  purchased_at TEXT NOT NULL, -- ISO 日期字串
  status TEXT NOT NULL CHECK (status IN ('DRAFT', 'APPROVED', 'RECEIVED', 'CANCELLED'))
);

CREATE TABLE purchase_items (
  purchase_item_id INTEGER PRIMARY KEY,
  purchase_id INTEGER NOT NULL REFERENCES purchases (purchase_id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products (product_id),
  qty INTEGER NOT NULL CHECK (qty > 0),
  unit_cost INTEGER NOT NULL CHECK (unit_cost >= 0)
);

-- 庫存異動：入庫/出庫/調整（用正負 qty 表示）
CREATE TABLE stock_moves (
  stock_move_id INTEGER PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products (product_id),
  moved_at TEXT NOT NULL, -- ISO 日期
  move_type TEXT NOT NULL CHECK (move_type IN ('IN', 'OUT', 'ADJUST')),
  qty INTEGER NOT NULL,
  ref TEXT
);

-- =========================
-- 範例資料（可展示用）
-- =========================

INSERT INTO suppliers (supplier_id, name, contact_email) VALUES
  (1, '明日供應股份有限公司', 'sales@tomorrow.example'),
  (2, '藍圖科技材料行', 'hello@blueprint.example'),
  (3, '北辰零件批發', 'ops@polaris.example');

INSERT INTO products (product_id, sku, name, category, unit_cost, is_active) VALUES
  (1, 'KB-001', '機械鍵盤 87 鍵', '周邊', 1890, 1),
  (2, 'MS-010', '無線滑鼠', '周邊', 690, 1),
  (3, 'HB-200', 'USB Hub 8 埠', '周邊', 980, 1),
  (4, 'CP-500', '公司用筆記型電腦', '設備', 28900, 1),
  (5, 'CM-110', '螢幕 27 吋', '設備', 6990, 1),
  (6, 'OT-999', '舊款轉接器（停售）', '周邊', 120, 0);

INSERT INTO purchases (purchase_id, supplier_id, purchased_at, status) VALUES
  (1001, 1, '2026-03-01', 'RECEIVED'),
  (1002, 2, '2026-03-12', 'RECEIVED'),
  (1003, 1, '2026-04-02', 'APPROVED'),
  (1004, 3, '2026-04-07', 'DRAFT'),
  (1005, 2, '2026-04-10', 'CANCELLED');

INSERT INTO purchase_items (purchase_item_id, purchase_id, product_id, qty, unit_cost) VALUES
  (1, 1001, 1, 10, 1800),
  (2, 1001, 2, 20, 650),
  (3, 1002, 3, 12, 950),
  (4, 1002, 5, 6, 6800),
  (5, 1003, 4, 3, 27900),
  (6, 1003, 5, 4, 6900),
  (7, 1004, 2, 10, 660),
  (8, 1004, 3, 8, 940),
  (9, 1005, 1, 5, 1750);

-- 依 RECEIVED 的採購入庫（簡化示範）
INSERT INTO stock_moves (stock_move_id, product_id, moved_at, move_type, qty, ref) VALUES
  (1, 1, '2026-03-03', 'IN', 10, 'PO#1001'),
  (2, 2, '2026-03-03', 'IN', 20, 'PO#1001'),
  (3, 3, '2026-03-14', 'IN', 12, 'PO#1002'),
  (4, 5, '2026-03-14', 'IN', 6, 'PO#1002');

-- 出庫（領用/出貨）
INSERT INTO stock_moves (stock_move_id, product_id, moved_at, move_type, qty, ref) VALUES
  (11, 2, '2026-03-20', 'OUT', -4, '領用：行政部'),
  (12, 1, '2026-03-21', 'OUT', -2, '領用：IT 部'),
  (13, 5, '2026-03-25', 'OUT', -1, '領用：設計部'),
  (14, 3, '2026-04-05', 'OUT', -3, '領用：行銷部');

-- 調整（盤點）
INSERT INTO stock_moves (stock_move_id, product_id, moved_at, move_type, qty, ref) VALUES
  (21, 2, '2026-04-12', 'ADJUST', 1, '盤點調整：+1'),
  (22, 3, '2026-04-12', 'ADJUST', -1, '盤點調整：-1');

