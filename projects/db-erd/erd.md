# ERD｜簽核領用 + 庫存（可展示作品）

## 設計重點（為什麼這樣拆）
- **單據與明細分開**：`issue_requests` / `issue_request_items`（避免重複欄位、支持多品項）
- **簽核紀錄獨立**：`approval_logs`（追溯「誰在何時做了什麼」）
- **庫存異動不可改**：`stock_moves` 寫入後不更新，只能用反向異動修正（可追溯）
- **角色/部門獨立**：方便做權限與報表（部門排行、主管待核准）

## ERD（Mermaid）

```mermaid
erDiagram
  departments ||--o{ users : has
  users ||--o{ issue_requests : creates
  departments ||--o{ issue_requests : owns
  issue_requests ||--o{ issue_request_items : contains
  products ||--o{ issue_request_items : requested
  issue_requests ||--o{ approval_logs : logs
  users ||--o{ approval_logs : acts
  products ||--o{ stock_moves : moves
  issue_requests ||--o{ stock_moves : fulfills

  departments {
    int department_id PK
    string name
  }

  users {
    int user_id PK
    int department_id FK
    string name
    string email
    string role
  }

  products {
    int product_id PK
    string sku
    string name
    string category
    int unit_cost
    int is_active
  }

  issue_requests {
    int request_id PK
    int requester_id FK
    int department_id FK
    string status
    string reason
    string needed_date
    string created_at
  }

  issue_request_items {
    int request_item_id PK
    int request_id FK
    int product_id FK
    int qty
  }

  approval_logs {
    int approval_log_id PK
    int request_id FK
    int approver_id FK
    string action
    string comment
    string acted_at
  }

  stock_moves {
    int stock_move_id PK
    int product_id FK
    int request_id FK
    string move_type
    int qty
    string moved_at
    string ref
  }
```

## 正規化（簡述）
- 產品資訊只放在 `products`
- 申請單主檔只放申請層級欄位（申請人、用途、狀態）
- 申請品項用明細表存多筆
- 簽核與庫存異動用「事件」概念獨立保存，避免修改歷史造成追溯困難

