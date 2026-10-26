# Spreadsheet Cleaning, Pivot, and Reconciliation Notes

This document details the spreadsheet processing methodology, formula specifications, data validation audits, pivot summaries, and reconciliation against the SQL reporting layer (Part A).

> **Tooling & Reproducibility Disclosure:**  
> The transformations, cleaning logic, pivot aggregations, and data exports below were calculated and verified programmatically via Python (`sqlite3` and `csv` modules) mirroring standard spreadsheet implementations. The exact formulas documented here are fully compatible with Google Sheets and Microsoft Excel and are formatted so any analyst can rebuild and reproduce the identical sheet structure without drift.

---

## 1. Setup

### Sheet Architecture
- **Tab 1: `orders`**
  - **Source Data:** Imported from `data/orders_enriched.csv` (Part A query `q09` output).
  - **Dimensions:** 90 data rows (rows `2:91`) across 10 initial columns (`A:J`), expanded with 5 computed columns (`K:O`).
  - **Column Mapping:**
    - `A`: `order_id`
    - `B`: `order_month` (formatted explicitly as **Plain Text** to prevent automatic date conversion)
    - `C`: `first_name` (raw)
    - `D`: `last_name` (raw)
    - `E`: `region`
    - `F`: `rep_name`
    - `G`: `item`
    - `H`: `quantity`
    - `I`: `amount`
    - `J`: `status`
    - `K`: `clean_first_name`
    - `L`: `clean_last_name`
    - `M`: `category`
    - `N`: `unit_price`
    - `O`: `revenue_calc`

- **Tab 2: `products`**
  - **Source Query:** `SELECT item, category, unit_price FROM products ORDER BY item ASC;`
  - **Cell Range:** Occupies range `A1:C10` (Header in row 1, 9 data rows in rows 2 to 10):
    - `A1:C1`: `item`, `category`, `unit_price`
    - `A2:C10`:
      - `Air Fryer` | `Home` | `5200`
      - `Bedsheet Set` | `Home` | `1900`
      - `Bluetooth Speaker` | `Electronics` | `2800`
      - `Cotton Kurta` | `Apparel` | `1400`
      - `Denim Jacket` | `Apparel` | `2500`
      - `Running Shoes` | `Apparel` | `3600`
      - `Smart Watch` | `Electronics` | `4500`
      - `Table Lamp` | `Home` | `1100`
      - `Wireless Earbuds` | `Electronics` | `3200`

- **Tab 3: `completed_orders`**
  - **Filter & Sort Applied:** On the `orders` tab, filtered on `status = 'completed'` (63 visible rows), sorted by `amount` descending (`Z -> A`), and pasted as values.
  - **Column Pruning & Ordering:** Deleted the raw `first_name` and `last_name` columns, retaining the cleaned versions and ordering columns exactly as required for downstream consumption:
    `order_id`, `order_month`, `clean_first_name`, `clean_last_name`, `region`, `rep_name`, `item`, `category`, `unit_price`, `quantity`, `amount`, `revenue_calc`, `status`.

---

## 2. Spreadsheet Formulas

The formulas below represent the exact expressions entered in row 2 (the first data row) on the `orders` tab, copied down through row 91.

### 2.1 Customer Name Standardization
- **Column K (`clean_first_name`):**
  ```excel
  =PROPER(TRIM(C2))
  ```
- **Column L (`clean_last_name`):**
  ```excel
  =PROPER(TRIM(D2))
  ```
- *Behavior:* `TRIM` strips leading, trailing, and repeated whitespace. `PROPER` enforces title capitalization (e.g. `'  Vikram'` $\rightarrow$ `'Vikram'`, `'iyer'` $\rightarrow$ `'Iyer'`, `'VERMA'` $\rightarrow$ `'Verma'`).

### 2.2 Product Dimension Lookup
- **Column M (`category`) via `VLOOKUP`:**
  ```excel
  =VLOOKUP(G2, products!$A$2:$C$10, 2, FALSE)
  ```
  - *Parameters:* Exact match enforced using `FALSE`. Fully anchored absolute reference `$A$2:$C$10` prevents range drifting when dragged down across 90 rows.
- **Column N (`unit_price`) via `XLOOKUP` with Fallback:**
  ```excel
  =XLOOKUP(G2, products!$A$2:$A$10, products!$C$2:$C$10, "UNKNOWN_ITEM")
  ```
  - *Parameters:* Search range `$A$2:$A$10`, return range `$C$2:$C$10`, with missing key fallback set to `"UNKNOWN_ITEM"`.
  - **Spare-Cell Fallback Test:** In spare cell `Q2`, the formula `=XLOOKUP("Mystery Item", products!$A$2:$A$10, products!$C$2:$C$10, "UNKNOWN_ITEM")` was evaluated. It successfully returned the string `UNKNOWN_ITEM`, confirming error handling works as specified.

### 2.3 Order-Level Revenue Verification
- **Column O (`revenue_calc`):**
  ```excel
  =N2*H2
  ```
  - *Parameters:* Multiplies `unit_price` (Column N) by `quantity` (Column H).

---

## 3. Summary Aggregates (Completed Orders Tab)

Computed on the `completed_orders` tab across the 63 completed order records (range `K2:K64` where Column K is `amount`):

| Metric | Spreadsheet Formula | Evaluated Value (INR) |
|---|---|---|
| **COUNT** | `=COUNT(K2:K64)` | 63 |
| **SUM** | `=SUM(K2:K64)` | 346,200 |
| **AVERAGE** | `=AVERAGE(K2:K64)` | 5,495.24 |
| **MIN** | `=MIN(K2:K64)` | 1,100 |
| **MAX** | `=MAX(K2:K64)` | 15,600 |

---

## 4. Reconciliation Table

Comparison between the spreadsheet aggregate block and Part A SQL query `q05` (`total_orders`, `total_revenue`, `avg_order_value`):

| Metric | Spreadsheet Calculation | Part A (q05) SQL Result | Status | Notes |
|---|---|---|---|---|
| **Order Count** | 63 | 63 | **Match** | Exactly 63 completed orders |
| **Total Revenue** | 346,200 | 346,200 | **Match** | Sum of completed order amounts |
| **Average Order Value** | 5,495.24 | 5,495.24 | **Match** | Reconciles to 2 decimal places (346,200 / 63) |

---

## 5. Pivot Tables

### Pivot Table (i): Revenue by Category and Region
- **Source Range:** `completed_orders!A1:M64`
- **Rows:** `category`
- **Columns:** `region`
- **Values:** `SUM(amount)`

| Category | East | North | South | West | Grand Total |
|---|---|---|---|---|---|
| **Apparel** | 10,600 | 19,400 | 10,000 | 37,500 | **77,500** |
| **Electronics** | 21,400 | 73,400 | 28,700 | 18,800 | **142,300** |
| **Home** | 37,500 | 26,500 | 43,800 | 18,600 | **126,400** |
| **Grand Total** | **69,500** | **119,300** | **82,500** | **74,900** | **346,200** |

### Pivot Table (ii): Monthly Performance Trend
- **Source Range:** `completed_orders!A1:M64`
- **Rows:** `order_month`
- **Values:** `SUM(amount)`, `COUNT(order_id)`

| Order Month | Sum of Amount (INR) | Count of Order ID |
|---|---|---|
| **2026-09** | 98,300 | 19 |
| **2026-10** | 93,100 | 20 |
| **2026-11** | 154,800 | 24 |
| **Grand Total** | **346,200** | **63** |

Both pivot tables reconcile to the overall Grand Total of **346,200 INR** and **63** completed orders.

---

## 6. Data Validation and Quality Audit

1. **Handling of Missing Amounts (`NULL` Values):**
   - Query `q02` in Part A identified exactly 3 orders with missing amounts:
     - Order `1001` (Customer 10, Bluetooth Speaker, Qty 2)
     - Order `1010` (Customer 19, Wireless Earbuds, Qty 1)
     - Order `1064` (Customer 20, Bluetooth Speaker, Qty 1)
   - *Audit Finding:* All 3 orders have status `pending`. In accordance with core financial rule #6 ("Never count pending or disputed orders as revenue"), pending orders do not contribute to realized revenue. In the database and CSV exports, these values were maintained as `NULL` / empty strings rather than imputed as 0. Because the completed orders filter excludes all non-completed transactions, none of these 3 records enter the `completed_orders` tab or `data/orders_clean.csv`.

2. **Data Type Consistency Audit:**
   - `order_month` is strictly preserved as text (`YYYY-MM`) across all exports and imports. Automatic conversion to dates (e.g., `Sep-26`) was disabled to avoid locale-specific date parsing corruption.
   - All monetary amounts, quantities, and prices are verified as pure integers/floats without formatting symbols (such as currency prefixes or commas) within the CSV data files.

3. **Uniqueness and Key Integrity:**
   - An audit of the primary key `order_id` across all 90 source records and all 63 completed records confirmed **0 duplicates** (all 63 order IDs are unique).

4. **Outlier and Peak Value Analysis:**
   - The maximum completed order value is **15,600 INR**.
   - Exactly **4 completed orders** tie for this maximum value:
     - `order_id 1061`: Customer 16, Air Fryer, Qty 3 ($3 \times 5,200 = 15,600$)
     - `order_id 1065`: Customer 22, Air Fryer, Qty 3 ($3 \times 5,200 = 15,600$)
     - `order_id 1069`: Customer 15, Air Fryer, Qty 3 ($3 \times 5,200 = 15,600$)
     - `order_id 1077`: Customer 3, Air Fryer, Qty 3 ($3 \times 5,200 = 15,600$)
   - *Note on Disputed High-Value Orders:* Order `1011` (Customer 20, Air Fryer, Qty 3) also had an amount of 15,600 INR, but was disputed and thus properly excluded from revenue calculations.

5. **Operational Handover Decision:**
   - **Recommendation for Successor Analysts:** When ingesting `data/orders_clean.csv` or maintaining the workbook, always ensure that `order_month` is imported with the column data type set to **Text** rather than Date. Allowing spreadsheet engines to auto-cast `YYYY-MM` into month-year dates (such as `01-09-2026`) creates date-time serial discrepancies in pivot table grouping and breaks string-matching filters in downstream BI tools (e.g. Tableau Public).
