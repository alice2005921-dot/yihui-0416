# 資料庫設計作品｜簽核領用 + 庫存（SQLite + ERD）

這個作品是「資料庫設計＋報表」的可展示範例：
- ERD（Mermaid）
- SQLite schema + 範例資料
- 常見報表查詢（領用排行、低庫存、申請到出庫時間）

## 檔案
- `erd.md`：ERD + 設計說明（正規化思路、關聯）
- `schema.sql`：建表 + 範例資料
- `queries.sql`：報表查詢

## 如何執行（SQLite）
在此資料夾執行：

```bash
sqlite3 demo.db < schema.sql
sqlite3 demo.db < queries.sql
```

