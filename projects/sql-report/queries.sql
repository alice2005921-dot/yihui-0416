.mode column
.headers on

-- ==========================================
-- 1) 採購總覽：每張採購單的金額與狀態
-- ==========================================
SELECT
  p.purchase_id                           AS 採購單號,
  s.name                                  AS 供應商,
  p.purchased_at                          AS 日期,
  p.status                                AS 狀態,
  SUM(pi.qty * pi.unit_cost)              AS 總金額
FROM purchases p
JOIN suppliers s ON s.supplier_id = p.supplier_id
JOIN purchase_items pi ON pi.purchase_id = p.purchase_id
GROUP BY p.purchase_id, s.name, p.purchased_at, p.status
ORDER BY p.purchased_at DESC;

-- ==========================================
-- 2) 依月份彙總：每月採購金額（排除取消）
-- ==========================================
SELECT
  substr(p.purchased_at, 1, 7)            AS 月份,
  COUNT(DISTINCT p.purchase_id)           AS 採購單數,
  SUM(pi.qty * pi.unit_cost)              AS 採購金額
FROM purchases p
JOIN purchase_items pi ON pi.purchase_id = p.purchase_id
WHERE p.status != 'CANCELLED'
GROUP BY substr(p.purchased_at, 1, 7)
ORDER BY 月份;

-- ==========================================
-- 3) Top-N：採購金額最高的前 5 個品項（排除取消）
-- ==========================================
SELECT
  pr.sku                                  AS SKU,
  pr.name                                 AS 品名,
  pr.category                             AS 類別,
  SUM(pi.qty)                             AS 採購數量,
  SUM(pi.qty * pi.unit_cost)              AS 採購金額
FROM purchase_items pi
JOIN purchases p ON p.purchase_id = pi.purchase_id
JOIN products pr ON pr.product_id = pi.product_id
WHERE p.status != 'CANCELLED'
GROUP BY pr.sku, pr.name, pr.category
ORDER BY 採購金額 DESC
LIMIT 5;

-- ==========================================
-- 4) 庫存即時量：每個品項的目前庫存（入出調整合計）
-- ==========================================
SELECT
  pr.sku                                  AS SKU,
  pr.name                                 AS 品名,
  pr.category                             AS 類別,
  SUM(sm.qty)                             AS 目前庫存
FROM products pr
LEFT JOIN stock_moves sm ON sm.product_id = pr.product_id
WHERE pr.is_active = 1
GROUP BY pr.sku, pr.name, pr.category
ORDER BY pr.category, pr.sku;

-- ==========================================
-- 5) 低庫存提醒：庫存 <= 5 的品項（可當管理報表）
-- ==========================================
WITH inv AS (
  SELECT
    pr.product_id,
    pr.sku,
    pr.name,
    pr.category,
    COALESCE(SUM(sm.qty), 0) AS on_hand
  FROM products pr
  LEFT JOIN stock_moves sm ON sm.product_id = pr.product_id
  WHERE pr.is_active = 1
  GROUP BY pr.product_id, pr.sku, pr.name, pr.category
)
SELECT sku AS SKU, name AS 品名, category AS 類別, on_hand AS 目前庫存
FROM inv
WHERE on_hand <= 5
ORDER BY on_hand ASC, SKU;

-- ==========================================
-- 6) 供應商績效（示範）：供應商採購金額與採購次數（排除取消）
-- ==========================================
SELECT
  s.name                                  AS 供應商,
  COUNT(DISTINCT p.purchase_id)           AS 採購次數,
  SUM(pi.qty * pi.unit_cost)              AS 採購金額
FROM suppliers s
JOIN purchases p ON p.supplier_id = s.supplier_id
JOIN purchase_items pi ON pi.purchase_id = p.purchase_id
WHERE p.status != 'CANCELLED'
GROUP BY s.name
ORDER BY 採購金額 DESC;

