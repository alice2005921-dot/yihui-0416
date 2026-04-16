# SQL 報表作品｜庫存與採購（SQLite）

這是一個可直接展示的 SQL 作品：包含「小型資料模型」、「範例資料」、「常見報表查詢」。

## 檔案
- `schema.sql`: 建表與範例資料
- `queries.sql`: 報表查詢（含註解）

## 如何使用（本機有 SQLite 即可）

在此資料夾執行：

```bash
sqlite3 demo.db < schema.sql
sqlite3 demo.db < queries.sql
```

你也可以進入互動模式：

```bash
sqlite3 demo.db
```

然後貼上 `queries.sql` 內的查詢。

## 我在這個作品想呈現什麼
- 能把「流程」轉成可查詢的「資料結構」
- 能用 SQL 做出「管理常見報表」：彙總、分組、JOIN、Top-N、趨勢
- 能在查詢中保持可讀性（命名、註解、拆解）

