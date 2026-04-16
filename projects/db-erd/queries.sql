.mode column
.headers on

-- 1) 申請總覽：狀態與申請人
SELECT
  r.request_id                       AS 申請單號,
  u.name                             AS 申請人,
  d.name                             AS 部門,
  r.status                           AS 狀態,
  r.reason                           AS 用途,
  r.created_at                       AS 建立日
FROM issue_requests r
JOIN users u ON u.user_id = r.requester_id
JOIN departments d ON d.department_id = r.department_id
ORDER BY r.created_at DESC;

-- 2) 目前庫存：以異動加總（on-hand）
SELECT
  p.sku                              AS SKU,
  p.name                             AS 品名,
  p.category                         AS 類別,
  COALESCE(SUM(m.qty), 0)            AS 目前庫存
FROM products p
LEFT JOIN stock_moves m ON m.product_id = p.product_id
WHERE p.is_active = 1
GROUP BY p.sku, p.name, p.category
ORDER BY 類別, SKU;

-- 3) 領用排行：依品項領用數量（OUT）
SELECT
  p.sku                              AS SKU,
  p.name                             AS 品名,
  SUM(-m.qty)                        AS 領用數量
FROM stock_moves m
JOIN products p ON p.product_id = m.product_id
WHERE m.move_type = 'OUT'
GROUP BY p.sku, p.name
ORDER BY 領用數量 DESC;

-- 4) 低庫存提醒（<= 5）
WITH inv AS (
  SELECT
    p.product_id,
    p.sku,
    p.name,
    COALESCE(SUM(m.qty), 0) AS on_hand
  FROM products p
  LEFT JOIN stock_moves m ON m.product_id = p.product_id
  WHERE p.is_active = 1
  GROUP BY p.product_id, p.sku, p.name
)
SELECT sku AS SKU, name AS 品名, on_hand AS 目前庫存
FROM inv
WHERE on_hand <= 5
ORDER BY on_hand ASC, SKU;

-- 5) 申請到核准的時間（示範）：用 created_at 到第一筆 APPROVE
SELECT
  r.request_id AS 申請單號,
  r.created_at AS 建立日,
  MIN(l.acted_at) AS 核准日,
  CAST(julianday(MIN(l.acted_at)) - julianday(r.created_at) AS INT) AS 核准耗時_天
FROM issue_requests r
JOIN approval_logs l ON l.request_id = r.request_id AND l.action = 'APPROVE'
GROUP BY r.request_id, r.created_at
ORDER BY 核准耗時_天 DESC;

