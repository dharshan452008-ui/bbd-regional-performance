# Big Billion Days Regional Performance Review — SQL, Spreadsheet, Dashboard and AI-Verified Analysis

An end-to-end, traceable commercial performance review analyzing Flipkart's Big Billion Days (BBD) sale across regions, product categories, and sales representatives. This project establishes a single verified analytics pipeline: SQLite database queries generate order-level facts, a spreadsheet layer standardizes and reconciles transactions, a BI dashboard specification models executive insights, and an AI governance log audits machine-generated claims against empirical facts.

---

## 1. Executive Summary of Key Findings

Across 63 completed orders during the three-month festive period (September–November 2026), the operation realized **₹346,200** in total revenue and delivered **106 units**, achieving an average order value of **₹5,495.24**. 
1. **North Dominance Driven by Electronics:** The North territory finished as the premier regional revenue driver with **₹119,300** (34.5% of national sales), outpacing second-ranked South (₹82,500) by 44.6% and East (₹69,500) by 71.7%. North's lead was heavily concentrated in consumer electronics (₹73,400), though its sales exhibited a severe monthly contraction from September (₹53,500) to November (₹24,500, a -54.2% drop).
2. **Late-Campaign Home Appliance Surge:** Realized revenue accelerated by **66.3%** from October (₹93,100, 20 orders) to November (₹154,800, 24 orders). This expansion was driven almost entirely by the Home category, which grew by **+560.3%** (from ₹12,600 to ₹83,200) due to concentrated multi-unit Air Fryer purchases, including four identical peak orders of 3 units at ₹15,600 each.
3. **Regional Category Specialization:** Consumer demand displayed marked geographic clustering. The West region established decisive leadership in Apparel, producing **₹37,500** (48.4% of all nationwide apparel revenue), whereas South and East derived over 50% of their revenues from Home goods (₹43,800 and ₹37,500 respectively).

---

## 2. Tools, Dialect, and Methodology Disclosure

In strict adherence to academic and technical integrity guidelines:
- **SQL Engine & Dialect:** Standard **SQLite** syntax executed reproducibly using Python's built-in `sqlite3` module (Python 3.14 on Windows 64-bit). No proprietary or external database servers were required.
- **Spreadsheet Processing:** Formulas (`PROPER`, `TRIM`, `VLOOKUP`, `XLOOKUP`, `COUNT`, `SUM`, `AVERAGE`, `MIN`, `MAX`) were specified to standard Google Sheets / Microsoft Excel specification. Transformations and pivot calculations were verified programmatically in Python (`csv` and `collections` modules) to guarantee exact mathematical replication without generating opaque binary `.xlsx` files.
- **BI Dashboard:** Authored as a comprehensive, text-only implementation blueprint in [`docs/dashboard_spec.md`](docs/dashboard_spec.md) for direct creation in Tableau Public. In accordance with Rule 7, we explicitly disclose that a live Tableau Public web session was not launched; the specification provides the complete field mapping, coordinates, containers, and data tables required for exact reproduction.
- **File Format Compliance:** All submitted artifacts are exclusively plain-text SQL (`.sql`), Markdown (`.md`), and comma-separated values (`.csv`).

---

## 3. Repository File Index

The repository adheres strictly to the required project layout, linking every deliverable to its respective project stage:

```
bbd-regional-performance/
│
├── README.md                      # Project documentation, findings, disclosures, and file index
│
├── sql/                           # Part A & Part D: SQL Reporting Layer
│   ├── 00_schema_and_seed.sql     # DDL and seed records (4 reps, 9 products, 24 customers, 90 orders)
│   ├── q01.sql                    # Pending orders query (19 rows)
│   ├── q02.sql                    # Orders with missing amounts query (3 rows)
│   ├── q03.sql                    # Top 5 completed orders by amount
│   ├── q04.sql                    # Target customer demographic filter (North/West, ages 25–40)
│   ├── q05.sql                    # Headline KPIs (Total orders: 63, Total revenue: ₹346,200)
│   ├── q06.sql                    # Order volume and revenue grouped by fulfillment status
│   ├── q07.sql                    # Strong products with completed revenue > ₹20,000
│   ├── q08.sql                    # Customer count and age distribution by region
│   ├── q09.sql                    # Enriched order-level fact table (all 90 orders)
│   ├── q10.sql                    # Unmatched customers who have never placed an order
│   ├── q11.sql                    # Region x month report with join rationale and distinct counts
│   ├── q12.sql                    # Product contribution tiers (High, Medium, Low)
│   ├── q13.sql                    # Sales rep monthly quota performance evaluation
│   └── d1_corrected.sql           # Part D: Corrected regional query (> ₹80k revenue threshold)
│
├── results/                       # Part A: Query Results Documentation
│   └── query_results.md           # Seed verification table and markdown output tables for q01–q13
│
├── data/                          # Fact Datasets
│   ├── orders_enriched.csv        # Part A (q09): 10 columns, header + 90 orders (empty NULLs)
│   └── orders_clean.csv           # Part B: 13 columns, header + 63 completed orders (amount sorted)
│
└── docs/                          # Parts B, C, & D: Analytical Documentation
    ├── spreadsheet_notes.md       # Part B: Formulas, 5 aggregates, 2 pivots, reconciliation, audit
    ├── dashboard_spec.md          # Part C: Tableau data roles, KPI cards, 4 chart specs, layout, narrative
    └── ai_log.md                  # Part D: Prompts, defect tables, MoM proof (-22.8%), HITL protocol
```

---

## 4. Analytical Assumptions & Decisions

Where the assignment brief afforded implementation latitude, the following decisions were established and consistently maintained:
1. **Financial Revenue Realization:** In accordance with core financial governance, *revenue* is defined strictly as `SUM(amount)` over orders where `status = 'completed'`. Pending (19 orders, ₹64,900) and disputed (8 orders, ₹73,200) orders are never recognized as realized revenue.
2. **Missing Amount Treatment:** Missing order amounts (`NULL` in orders `1001`, `1010`, `1064`) were preserved as `NULL` in the database and exported as empty string fields (`""`) in CSVs. They were not imputed with zeros or mean values to avoid distorting average order metrics. Because all three have status `pending`, they were naturally excluded from the completed orders layer.
3. **Date Formatting Integrity:** `order_month` is strictly maintained as plain text (`YYYY-MM`) across all CSVs and tables. Spreadsheet and BI automatic type-casting to date serials was suppressed to avoid regional formatting corruption (e.g. `Sep-26` vs `01/09/2026`).
4. **Tie-Breaking in Sorts:** For queries requiring descending sorts (such as `q03` and the Part B spreadsheet sort on `amount`), ties were resolved deterministically using `order_id ASC` in SQL, and stable insertion order in spreadsheet operations.
5. **Causality vs. Correlation:** Observed sales concentrations (such as November's Home appliance surge or West's Apparel dominance) are reported as empirical demand patterns. Causal attribution to specific advertising campaigns or warehouse stock-outs is explicitly avoided because marketing spend and inventory logs were not present in the relational schema.

---

## 5. End-to-End Verification Checkpoint

All stages of the pipeline reconcile to the exact same core truth:

$$\text{SQL q05} = \text{Spreadsheet SUM} = \text{Pivot Grand Total} = \text{Dashboard Revenue KPI} = \mathbf{₹346,200}$$

$$\text{Completed Orders} = \mathbf{63} \quad | \quad \text{Total Units Sold} = \mathbf{106} \quad | \quad \text{Source Orders Preserved} = \mathbf{90}$$
