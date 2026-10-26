# AI Assistance, Governance, and Human-in-the-Loop Verification Log

This document provides the complete record of AI prompt engineering, error diagnosis, empirical query verification, and human-in-the-loop governance protocols in accordance with the project rules.

---

## Part A: Five-Component Prompt for Query `q13.sql`

The following prompt was structured to instruct an AI assistant to author Part A's sales representative performance query (`sql/q13.sql`) without hallucinations or syntax errors.

```markdown
### Prompt Specification

**Role:**  
You are an expert SQL engineer and analytics database developer specializing in SQLite business intelligence queries.

**Task:**  
Write a clean, standards-compliant SQL query that computes sales representative monthly quota attainment and categorizes their performance into three specific tiers.

**Context:**  
The relational database runs on SQLite (using standard SQLite syntax) and consists of the following real tables and columns:
- `reps`: `rep_id` (INTEGER), `rep_name` (VARCHAR), `region` (VARCHAR), `monthly_target` (INTEGER)
- `customers`: `customer_id` (INTEGER), `first_name` (VARCHAR), `last_name` (VARCHAR), `city` (VARCHAR), `region` (VARCHAR), `age` (INTEGER), `rep_id` (INTEGER)
- `orders`: `order_id` (INTEGER), `customer_id` (INTEGER), `item` (VARCHAR), `quantity` (INTEGER), `amount` (INTEGER), `status` (VARCHAR), `order_month` (VARCHAR)

Relationships: `reps.rep_id = customers.rep_id` and `customers.customer_id = orders.customer_id`.

**Constraints:**  
1. Revenue Definition: Include ONLY completed orders (`orders.status = 'completed'`). Pending and disputed orders must be excluded.
2. Columns to Return: `rep_name`, `order_month`, `monthly_target`, `revenue` (alias for the completed order sum), and `performance_tier`.
3. Performance Tier Rules: Compute directly using an explicit `CASE` expression evaluated on the aggregate:
   - `'Below Target'` when `SUM(orders.amount) < reps.monthly_target`
   - `'On Target'` when `SUM(orders.amount) >= reps.monthly_target AND SUM(orders.amount) < 1.1 * reps.monthly_target`
   - `'Above Target'` otherwise.
   Do not reference derived column aliases or aggregates in a `WHERE` clause.
4. Dialect & Architecture Constraints: Do NOT use Common Table Expressions (`WITH` clauses), subqueries, window functions, or stored procedures.
5. Qualification & Grouping: Explicitly qualify all column names with their respective table aliases (`r.`, `c.`, `o.`). Group by `r.rep_name`, `o.order_month`, and `r.monthly_target`.
6. Ordering: Order results by `r.rep_name ASC`, then `o.order_month ASC`.

**Format:**  
Output raw SQL code only, prefixed with a one-line SQL comment stating the business question. Include inline SQL comments explaining join conditions and tier boundary logic.
```

---

## Part B: Inspection of Scenario D1

### Scenario D1 Background
A colleague submitted the vague question *"which regions sell the most?"* to an unconstrained AI assistant, which provided the following response:

```sql
SELECT region_name, SUM(total_sales) AS sales
FROM sales
WHERE SUM(total_sales) > 80000
GROUP BY region_name
ORDER BY sales DESC;
```
> *"North is the strongest region, and its revenue grew 38% month over month."*

### Defect Analysis
An technical inspection of the assistant's query and prose claim reveals four distinct critical defects:

| # | Defect Identified | Defect Classification | Detailed Technical Analysis & Required Fix |
|:---:|---|:---:|---|
| **1** | **Non-existent table `sales`** | `fake method/function` | The database schema has no table named `sales`. The raw order transactions reside in `orders`, regional metadata in `customers`, and representative data in `reps`.<br>**Fix:** Query `customers AS c JOIN orders AS o ON c.customer_id = o.customer_id`. |
| **2** | **Non-existent columns `region_name` and `total_sales`** | `fake method/function` | The columns `region_name` and `total_sales` do not exist in the database. Customer territories are stored in `customers.region` and transactional values in `orders.amount`.<br>**Fix:** Reference `c.region` and `SUM(o.amount)`. |
| **3** | **Aggregate expression in `WHERE` clause** | `logic error` | `WHERE SUM(total_sales) > 80000` violates standard SQL query execution order. The `WHERE` clause filters individual table rows *before* aggregation occurs; aggregate expressions must be evaluated in a `HAVING` clause *after* `GROUP BY`.<br>**Fix:** Apply row-level status filtering in `WHERE o.status = 'completed'` and place the group threshold in `HAVING SUM(o.amount) > 80000`. |
| **4** | **Unsupported claim of +38% MoM growth in North** | `phantom statistic` | The assistant asserted without calculation that *"North is the strongest region, and its revenue grew 38% month over month."* When evaluated against the verified transactional data, North's revenue experienced a steep decline, making this a hallucinated statistic.<br>**Fix:** Calculate the actual percentage change from verified query `q11` facts ($ -22.8\% $). |

---

## Part C: Empirical Verification of `sql/d1_corrected.sql`

### 1. Corrected Query Execution
The corrected query was authored and saved to [`sql/d1_corrected.sql`](file:///d:/bbd-regional-performance/sql/d1_corrected.sql):

```sql
-- Business Question: Which regions have completed-order revenue exceeding 80,000?
SELECT
    c.region,
    SUM(o.amount) AS sales
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.region
HAVING SUM(o.amount) > 80000
ORDER BY sales DESC;
```

Executing this query against the seeded SQLite database produced exactly **2 rows**:

| `region` | `sales` (INR) |
|---|:---:|
| **North** | 119,300 |
| **South** | 82,500 |

*(West at ₹74,900 and East at ₹69,500 were correctly excluded as their revenues do not exceed the 80,000 INR threshold).*

### 2. North Month-over-Month Revenue Calculation
From the executed output of query `q11` ([`sql/q11.sql`](file:///d:/bbd-regional-performance/sql/q11.sql)), North's verified monthly completed revenues are:
- **September 2026 (`2026-09`):** ₹53,500 (8 completed orders)
- **October 2026 (`2026-10`):** ₹41,300 (6 completed orders)
- **November 2026 (`2026-11`):** ₹24,500 (5 completed orders)

Calculating North's revenue change from September 2026 to October 2026:

$$\text{MoM Change} = \frac{\text{Revenue}_{\text{Oct}} - \text{Revenue}_{\text{Sep}}}{\text{Revenue}_{\text{Sep}}} \times 100\% = \frac{41,300 - 53,500}{53,500} \times 100\% = \frac{-12,200}{53,500} \times 100\% = -22.8037\% \approx \mathbf{-22.8\%}$$

### 3. Conclusion on Assistant's Claim
The AI assistant's claim that North's revenue *"grew 38% month over month"* is **completely false and contradicted by the empirical data**. In reality, North contracted by **-22.8%** between September and October 2026, and dropped by a further -40.7% in November.

---

## Part D: Five-Step Human-in-the-Loop Protocol

1. **Specification:**  
   Prompt specifications must define the exact business definitions, schema constraints, and target dialect before requesting code. When a user asks an unconstrained, underspecified question like *"which regions sell the most?"*, the assistant hallucinates convenient table names (`sales`) and imaginary metrics (`total_sales`). Grounding the assistant with explicit DDL structures, business rules (e.g., realized revenue = completed orders only), and SQL dialect constraints prevents initial structural drift.

2. **Execution:**  
   Code produced by an AI assistant must be executed in a live, reproducible environment (such as Python's `sqlite3` engine) rather than visually skimmed. In Scenario D1, running the raw code immediately triggers fatal syntax and runtime errors: SQLite rejects `FROM sales` because the table does not exist, and would reject `WHERE SUM(...)` because aggregate functions are prohibited in the `WHERE` clause. Execution serves as the first non-negotiable filter.

3. **Inspection:**  
   Human code review must systematically inspect relational syntax, join logic, and aggregation semantics against established SQL compilation phases. In Scenario D1, inspection reveals that the query confuses row-level filtering with group-level filtering by placing `SUM()` in `WHERE`, omits order fulfillment state filtering (`status = 'completed'`), and fails to perform table joins between customers and order lines.

4. **Verification:**  
   Every numerical claim or prose assertion generated by AI must be audited against downstream query outputs. While North was indeed the top revenue-generating region overall (₹119,300), the assistant's quantitative narrative that North *"grew 38% month over month"* was entirely fabricated. Cross-referencing against the verified query `q11` facts proved that North actually contracted by -22.8% from September to October.

5. **Decision:**  
   - **Original AI Answer:** **REJECTED.** The query fails compilation due to non-existent tables/columns and syntax errors, lacks fulfillment status filtering, and asserts a fabricated +38% growth statistic contradicted by empirical transaction records.  
   - **Corrected Query (`sql/d1_corrected.sql`):** **ACCEPTED.** The corrected query successfully executes on SQLite, adheres to qualified join semantics and `HAVING` clause aggregation, and produces verified outputs (North ₹119,300 and South ₹82,500) that perfectly reconcile with Part B's pivot tables and Part C's dashboard rollups.

---

## Part E: Scenario D2 Prompt and Root-Cause Diagnosis

### 1. Five-Component Diagnosis Prompt

```markdown
### Prompt Specification

**Role:**  
You are an expert spreadsheet analyst and Google Sheets/Excel formula debugger.

**Task:**  
Diagnose the root cause of a `#N/A` lookup failure in an e-commerce workbook and provide the exact repaired formula.

**Context:**  
- The workbook has an `orders` tab and a `products` tab.
- The `products` tab contains a master price table in cell range `products!$A$2:$C$10` (Row 1 is the header; Column A contains item names, Column B contains categories, and Column C contains unit prices).
- In the `products` table, cell `A8` contains the text `"Smart Watch"` and cell `C8` contains `4500`.
- On the `orders` tab, cell `G2` contains the string `" Smart Watch"` (note the leading whitespace character before the letter 'S').
- The current formula entered in cell `N2` is:
  `=VLOOKUP(G2, products!$A$2:$C$10, 3, FALSE)`

**Constraints:**  
- The formula must retrieve the unit price (`4500`) for the item named in `G2`.
- Exact matching (`FALSE`) must be preserved.
- The formula must be robust against whitespace discrepancies without manually editing the raw source string in cell `G2`.

**Format:**  
Explain the exact technical root cause in one concise paragraph, followed by the corrected single-cell formula ready to copy down.
```

### 2. Root Cause Explanation
The lookup fails with a `#N/A` error because the final argument of `VLOOKUP` is set to `FALSE`, enforcing a strict byte-for-byte exact character match. The value in cell `G2` is `" Smart Watch"`, which contains a leading ASCII space character (ASCII 32). In contrast, the key in `products!$A$2:$A$10` is cleanly stored as `"Smart Watch"`. Because `" Smart Watch"` $\neq$ `"Smart Watch"`, the exact-match scan fails to find an identical key and triggers an error.

### 3. Repaired Formula
To fix the lookup failure without altering source order data, wrap the lookup key `G2` in the `TRIM()` function to purge leading, trailing, and duplicate spaces before evaluation:

```excel
=VLOOKUP(TRIM(G2), products!$A$2:$C$10, 3, FALSE)
```

---

## Part F: Skeptical-Analyst Challenge on Recommendation 1

### 1. Skeptical Analyst Prompt

```markdown
### Prompt Specification

**Role:**  
You are a highly skeptical senior operations auditor and supply chain economist. Your job is to rigorously pressure-test recommendations by uncovering unstated operational assumptions, confounding variables, and confusing correlation with causation.

**Task:**  
Critique Recommendation 1 from the BBD Regional Performance Review dashboard ("Reallocate Home Appliance Fulfillment and Buffers to South and East Hubs").

**Context:**  
The recommendation advocates shifting centralized Air Fryer safety stock and pre-staging inventory in Bengaluru (South) and Kolkata (East) regional fulfillment centers based on the fact that South and East generated 64.3% of completed Home category revenue (₹81,300 of ₹126,400) during the 3-month festive window.

**Constraints:**  
1. Identify at least three unstated operational or commercial assumptions behind this recommendation.
2. For each assumption, specify a concrete empirical metric, data check, or transaction log from the dataset that would confirm or weaken it.
3. Challenge whether the November surge demonstrates durable regional consumer demand versus short-term promotional distortion or bulk-buying anomalies.

**Format:**  
Provide a structured analysis with numbered assumptions, the operational risk of each, and the specific data check required.
```

### 2. Unstated Assumptions and Empirical Data Checks

1. **Assumption 1: November's Home revenue surge reflects steady regional consumer demand rather than a non-recurring bulk purchase anomaly.**  
   - *Operational Risk:* If the volume surge was caused by a handful of one-off institutional or reseller purchases, moving permanent safety stock to Bengaluru and Kolkata will tie up working capital and incur dead inventory carrying costs.  
   - *Verifying Data Check:* Inspect order granularity in [`data/orders_clean.csv`](file:///d:/bbd-regional-performance/data/orders_clean.csv). In November 2026, Home sales spiked to ₹83,200, but **₹62,400 (75.0%)** of this total was generated by just **four identical orders** of 3 Air Fryers at ₹15,600 each (`1061`, `1065`, `1069`, `1077`). In East, two customers (`15` and `3`) placed 3-unit Air Fryer orders on the same day. This extreme transaction concentration weakens the assumption of broad-based household demand.

2. **Assumption 2: Lost revenue or delivery delays were caused by regional stock-outs rather than non-inventory fulfillment bottlenecks.**  
   - *Operational Risk:* Reallocating physical inventory does nothing to improve sales if historical order leakage was driven by payment gateway failures, credit verification delays, or product return disputes.  
   - *Verifying Data Check:* Audit the pending and disputed order logs in Part A queries `q01` and `q06`. The database contains 8 disputed orders totaling ₹73,200 and 19 pending orders totaling ₹64,900. Notably, order `1003` (Air Fryer, South, ₹10,400) and order `1011` (Air Fryer, West, ₹15,600) were tagged as `disputed`, not cancelled for lack of inventory. If regional orders are hung up in billing disputes, physical warehouse reallocation will not improve realized revenue.

3. **Assumption 3: The absolute unit velocity of Air Fryers justifies decentralized regional warehouse holding costs.**  
   - *Operational Risk:* Air Fryers are bulky, high-cube appliances with elevated pallet-storage costs. Decentralizing buffer stock into secondary regional warehouses requires high inventory turns to remain cost-effective.  
   - *Verifying Data Check:* Check total unit sales across the 3-month campaign from `data/orders_clean.csv`. Across the entire quarter, total completed Air Fryer sales amounted to **20 units nationwide** (East: 6 units; North: 4 units; South: 6 units; West: 4 units). An average demand velocity of approximately **2 units per month per region** is insufficient to justify dedicated warehouse space, safety stock buffers, and inter-facility transfer freight. Centralized hub-and-spoke fulfillment is far more capital-efficient.

---

## Part G: Comprehensive Verification Audit and Disclosure

Every claim, formula, metric, and percentage cited across this project has been cross-verified against the underlying SQLite database engine and exported CSV fact tables:

- **Seed Row Counts:** Verified via `SELECT COUNT(*)` (`reps`: 4, `products`: 9, `customers`: 24, `orders`: 90).
- **Core Realized Revenue:** Verified across Part A (`q05`), Part B (Reconciliation Block & Pivot Tables), and Part C (KPI Cards & Four-Way Reconciliation) as exactly **₹346,200** across **63 completed orders**.
- **Query Outputs `q01`–`q13`:** Executed programmatically using Python's built-in `sqlite3` module; row counts match all acceptance criteria.
- **Scenario D1 Verification:** Corrected query `sql/d1_corrected.sql` executed against seeded SQLite tables, returning North (₹119,300) and South (₹82,500). North's MoM growth was verified as **-22.8%**, formally disproving the AI assistant's +38% claim.
- **Tooling Disclosure:** No external unverified AI services or closed proprietary tools were used to fabricate data; all analytical workflows are fully reproducible via standard Python 3.
