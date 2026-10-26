# Big Billion Days Regional Performance Dashboard Specification

This document provides the complete, production-grade technical specification for authoring the executive dashboard in **Tableau Public** (or equivalent modern BI suites) using the verified fact dataset [`data/orders_clean.csv`](file:///d:/bbd-regional-performance/data/orders_clean.csv).

> **Tooling & Verification Disclosure:**  
> All underlying metrics, coordinates, table values, and layout constraints documented herein were derived programmatically and verified against the executed database queries (Part A) and spreadsheet reconciliation models (Part B). Tableau Public was not launched in this environment; this document serves as the complete implementation blue-print for any BI analyst to recreate the dashboard with exact fidelity.

---

## 1. Data Source Architecture

- **Data Connection:** Connect to `data/orders_clean.csv`.
- **Row Count:** 63 completed order transactions (Header + 63 data rows).
- **Field Classifications:** All 13 columns are mapped to exact Tableau data roles (9 Dimensions and 4 Measures):

| Column # | Field Name | Data Type | Tableau Role | Description |
|:---:|---|---|:---:|---|
| 1 | `order_id` | Number (Whole) | **Dimension** | Discrete primary order transaction identifier (not an additive measure). |
| 2 | `order_month` | String / Text | **Dimension** | Temporal reporting cohort (`2026-09`, `2026-10`, `2026-11`). |
| 3 | `clean_first_name` | String / Text | **Dimension** | Standardized customer given name. |
| 4 | `clean_last_name` | String / Text | **Dimension** | Standardized customer family name. |
| 5 | `region` | String / Text | **Dimension** | Geographic sales territory (`East`, `North`, `South`, `West`). |
| 6 | `rep_name` | String / Text | **Dimension** | Assigned regional account sales representative. |
| 7 | `item` | String / Text | **Dimension** | Specific product SKU name (9 distinct items). |
| 8 | `category` | String / Text | **Dimension** | Product merchandise department (`Apparel`, `Electronics`, `Home`). |
| 9 | `unit_price` | Number (Whole) | **Measure** | List price per unit in Indian Rupees (INR). |
| 10 | `quantity` | Number (Whole) | **Measure** | Order volume / number of units purchased. |
| 11 | `amount` | Number (Whole) | **Measure** | Total realized transaction value in Indian Rupees (INR). |
| 12 | `revenue_calc` | Number (Whole) | **Measure** | Audited order revenue (`unit_price * quantity`). |
| 13 | `status` | String / Text | **Dimension** | Order fulfillment state (strictly filtered to `completed`). |

*Summary:* Exactly **9 Dimensions** and **4 Measures**.

---

## 2. KPI Summary Cards

Placed at the top of the executive view to establish immediate business context:

### KPI Card 1: Total Realized Revenue
- **Card Title:** Total Revenue
- **Primary Field:** `SUM(amount)`
- **Display Format:** Currency format `₹#,##0` (INR)
- **Target Value:** **₹346,200**
- **Reconciliation Note:** This value exactly equals Part A's query `q05` `total_revenue` (346,200 INR) and matches the Part B spreadsheet reconciliation summary.

### KPI Card 2: Total Units Sold
- **Card Title:** Total Units Sold
- **Primary Field:** `SUM(quantity)`
- **Display Format:** Number `#,##0 Units`
- **Target Value:** **106 Units**
- **Reconciliation Note:** Sum of `quantity` across all 63 completed orders in `data/orders_clean.csv`.

---

## 3. Worksheets Specification

### Worksheet 1: Revenue by Region
- **Chart Type:** Horizontal Bar Chart
- **Shelves Configuration:**
  - **Rows:** `region` (sorted descending by `SUM(amount)`)
  - **Columns:** `SUM(amount)`
  - **Color:** `region` (qualitative categorical palette)
  - **Label:** `SUM(amount)` formatted as `₹#,##0`
- **Design Rationale:** Horizontal bar charts provide an intuitive common baseline, making variance and ranking among regional sales territories immediately discernible to executive leadership.
- **Plotted Data Table:**

| Region | Realized Revenue (INR) | % of Total Revenue |
|---|:---:|:---:|
| **North** | 119,300 | 34.46% |
| **South** | 82,500 | 23.83% |
| **West** | 74,900 | 21.63% |
| **East** | 69,500 | 20.08% |
| **Total** | **346,200** | **100.00%** |

---

### Worksheet 2: Revenue by Category
- **Chart Type:** Horizontal Bar Chart
- **Shelves Configuration:**
  - **Rows:** `category` (sorted descending by `SUM(amount)`)
  - **Columns:** `SUM(amount)`
  - **Color:** `category`
  - **Label:** `SUM(amount)` formatted as `₹#,##0`
- **Design Rationale:** Clearly highlights the relative contribution of each product line, allowing category managers to gauge portfolio skew at a glance.
- **Plotted Data Table:**

| Category | Realized Revenue (INR) | % of Total Revenue |
|---|:---:|:---:|
| **Electronics** | 142,300 | 41.10% |
| **Home** | 126,400 | 36.51% |
| **Apparel** | 77,500 | 22.39% |
| **Total** | **346,200** | **100.00%** |

---

### Worksheet 3: Revenue Trend by Month and Category
- **Chart Type:** Multi-Line Time Series Chart
- **Shelves Configuration:**
  - **Rows:** `SUM(amount)`
  - **Columns:** `order_month` (Discrete Dimension)
  - **Color:** `category` (3 distinct colored line series: Apparel, Electronics, Home)
  - **Marks / Detail:** Line mark with data points enabled; tooltips displaying Month, Category, and Revenue.
- **Design Rationale:** Multi-line charts excel at showing sequential trajectory, inflection points, and divergent category momentum across consecutive billing cycles.
- **Plotted Data Table:**

| Order Month | Apparel (INR) | Electronics (INR) | Home (INR) | Monthly Total (INR) |
|---|:---:|:---:|:---:|:---:|
| **2026-09** | 24,700 | 43,000 | 30,600 | **98,300** |
| **2026-10** | 30,600 | 49,900 | 12,600 | **93,100** |
| **2026-11** | 22,200 | 49,400 | 83,200 | **154,800** |
| **Category Total** | **77,500** | **142,300** | **126,400** | **346,200** |

---

### Worksheet 4: Region x Category Detail
- **Chart Type:** Cross-tabulation Text Table
- **Shelves Configuration:**
  - **Rows:** `region`
  - **Columns:** `category`
  - **Marks / Text:** `SUM(amount)`
  - **Grand Totals:** Row Grand Totals and Column Grand Totals enabled.
- **Design Rationale:** Supplies precise numeric reference values for category managers conducting operational reviews and quota audits across regional desks.
- **Plotted Data Table:**

| Region | Apparel (INR) | Electronics (INR) | Home (INR) | Regional Total (INR) |
|---|:---:|:---:|:---:|:---:|
| **East** | 10,600 | 21,400 | 37,500 | **69,500** |
| **North** | 19,400 | 73,400 | 26,500 | **119,300** |
| **South** | 10,000 | 28,700 | 43,800 | **82,500** |
| **West** | 37,500 | 18,800 | 18,600 | **74,900** |
| **Grand Total** | **77,500** | **142,300** | **126,400** | **346,200** |

---

## 4. Dashboard Layout & Interactivity

### 4.1 Layout Hierarchy
- **Canvas Size:** Fixed Dashboard Size: 1366 px width $\times$ 900 px height (optimal for modern desktop displays).
- **Structure (Top to Bottom):**
  1. **Header & KPI Container (Horizontal):** Title block (*"Big Billion Days Regional Performance Review"*) alongside two KPI scorecards (*Total Revenue: ₹346,200* and *Total Units Sold: 106*).
  2. **Interactive Global Control Band (Horizontal):** Placed directly below the KPI header, housing the `category` filter control.
  3. **Trend Container (Vertical, Full Width):** Housing *Worksheet 3: Revenue Trend by Month and Category* to provide immediate macro-level trajectory visibility.
  4. **Comparison Container (Horizontal, Split 50/50):** Housing *Worksheet 1: Revenue by Region* on the left and *Worksheet 2: Revenue by Category* on the right.
  5. **Detail Container (Vertical, Full Width):** Housing *Worksheet 4: Region x Category Detail* text table at the bottom for auditability.

### 4.2 Interactive Actions & Global Filtering
- **Category Global Filter:** Configured with target scope: **"Apply to All Worksheets Using This Data Source"**. Selecting or deselecting a category instantly rescales the KPIs, trend curves, regional rankings, and detail cross-tab across the entire board.
- **Use as Filter (Cross-Filtering):** Enabling **"Use as Filter"** on *Worksheet 1: Revenue by Region* configures an interactive dashboard action. When an executive clicks the **North** bar, Tableau passes a filter on `region = 'North'` to the other three sheets:
  - *Worksheet 2 (Revenue by Category)* updates to show North's category breakdown (Electronics ₹73,400, Home ₹26,500, Apparel ₹19,400).
  - *Worksheet 3 (Revenue Trend)* filters its lines to show North's monthly evolution.
  - *Worksheet 4 (Detail Table)* collapses to display only the North row.

---

## 5. Insight and Recommendation Narrative

### 5.1 Visualization Summary
The dashboard consolidates commercial performance from Flipkart's Big Billion Days event spanning September through November 2026. Across 63 completed orders, the operation generated **₹346,200** in total net revenue from **106 units sold**. Commercial performance is anchored by Electronics (₹142,300) and Home (₹126,400), with North emerging as the premier territorial driver (₹119,300).

### 5.2 Summary Analysis (Empirical Observations)
1. **Regional Variance and North Leadership:**  
   North led all sales territories with **₹119,300** in realized revenue (34.5% of total sales), outperforming the second-ranked South region (**₹82,500**) by **44.6%** (+₹36,800) and generating **71.7%** more revenue than East (**₹69,500**). North's market lead was heavily concentrated in high-value consumer tech: Electronics alone contributed **₹73,400** (61.5% of North's regional revenue), where Arjun Mehta closed high-ticket items like Smart Watches and Wireless Earbuds.
2. **Monthly Surge and Home Appliance Volatility:**  
   Total sales expanded by **66.3%** between October (**₹93,100**, 20 orders) and November (**₹154,800**, 24 orders). This end-of-campaign growth was overwhelmingly driven by the Home category, which expanded from **₹12,600** in October to **₹83,200** in November (a **+560.3%** increase). This explosive rise was fueled by clustered multi-unit Air Fryer purchases, including four identical 3-unit completed orders totaling **₹15,600** each (orders `1061`, `1065`, `1069`, `1077`).
3. **Territorial Specialization (West Apparel Focus):**  
   While Apparel ranked third nationally (**₹77,500**), demand exhibited extreme regional clustering. West generated **₹37,500** in Apparel sales, capturing nearly half (**48.4%**) of nationwide Apparel revenue and accounting for **50.1%** of West's total intake (₹74,900). In contrast, South generated only ₹10,000 in Apparel, relying instead on Home goods (₹43,800, 53.1% of South sales).

> **Methodological Note on Causality:**  
> The data confirms strong temporal and regional correlations (e.g. November peak and West apparel concentration). However, because marketing expenditure logs, inventory stock-out histories, and promotional markdown schedules are not tracked in the four transactional tables, we treat these patterns as empirical demand observations rather than proven causal outcomes of specific ad spend or inventory availability.

### 5.3 Actionable Recommendations
1. **Reallocate Home Appliance Fulfillment and Buffers to South and East Hubs:**  
   *Action:* Shift centralized Air Fryer safety stock and pre-stage fulfillment inventory in Bengaluru and Kolkata regional logistics hubs ahead of future peak festive windows.  
   *Supporting Data:* South and East collectively accounted for **64.3%** of all completed Home revenue (**₹81,300** of ₹126,400), with Home representing over 50% of revenue in both territories (₹43,800 in South, ₹37,500 in East).  
   *Metric to Monitor:* Regional stock-out frequency during peak sale days and regional order fulfillment cycle time (hours from order to dispatch).
2. **Deepen Apparel Merchandising and Regional Seller Partnerships in West:**  
   *Action:* Expand merchant onboarding for ethnic and casual apparel brands native to Mumbai, Pune, and Ahmedabad, and deploy targeted digital regional banners in the West region.  
   *Supporting Data:* West generated **₹37,500** in completed Apparel revenue across 9 orders—generating nearly double the Apparel sales of the next highest region (North at ₹19,400) and almost four times South (₹10,000).  
   *Metric to Monitor:* West Apparel monthly active transacting customers and Average Order Value (AOV) for West Apparel baskets.
3. **Remediate Arjun Mehta's Momentum Decline in North Electronics:**  
   *Action:* Implement bundled promotional packages combining Smart Watches (unit price ₹4,500) and Wireless Earbuds (₹3,200) to reinvigorate North consumer tech sales following a severe November slump.  
   *Supporting Data:* North's monthly revenue deteriorated from **₹53,500** in September to **₹41,300** in October, dropping to **₹24,500** in November (a **-54.2%** peak-to-trough contraction). Arjun Mehta missed his ₹40,000 monthly quota in November, falling to 'Below Target' status despite holding 51.6% of national Electronics demand.  
   *Metric to Monitor:* Arjun Mehta's monthly target realization percentage and the repeat-purchase frequency of North electronics customers.

---

## 6. Four-Way Revenue Reconciliation

To guarantee integrity across every reporting layer, all primary revenue rollups reconcile to an identical total:

| Reporting Layer | Calculated Revenue Total (INR) | Reconciliation Status |
|---|:---:|:---:|
| **1. Total Revenue KPI Card** | ₹346,200 | **Match** |
| **2. Sum of Worksheet 1 (Revenue by Region)** | ₹346,200 | **Match** |
| **3. Sum of Worksheet 2 (Revenue by Category)** | ₹346,200 | **Match** |
| **4. Part B Pivot Table Grand Total** | ₹346,200 | **Match** |

$$\text{Total Revenue KPI (346,200)} = \sum \text{Region (346,200)} = \sum \text{Category (346,200)} = \text{Part B Grand Total (346,200)}$$

Every number is verified against [`data/orders_clean.csv`](file:///d:/bbd-regional-performance/data/orders_clean.csv) and Part A's [`sql/q05.sql`](file:///d:/bbd-regional-performance/sql/q05.sql).
