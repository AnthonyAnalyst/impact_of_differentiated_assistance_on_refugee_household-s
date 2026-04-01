#  Kakuma Refugee Camp — Differentiated Assistance Analysis

> A data analytics project examining household vulnerability, food security, and assistance targeting across **~17,000 households** at Kakuma Refugee Camp, Kenya.

---

##  Project Overview

This project analyzes whether humanitarian assistance at Kakuma Refugee Camp is effectively differentiated and targeted based on household vulnerability. It investigates relationships between vulnerability categories, food security, income sources, debt levels, and assistance received — providing evidence-based insights for aid optimization.

The analysis spans three tools: **SQL**, **Python (Jupyter Notebook)**, and **Power BI**, forming a complete end-to-end data analytics pipeline.

---

## Project Files

| File | Description |
|------|-------------|
| `1-_kakuma_differentiated_assistance_synthetic_dataset.csv` | Synthetic dataset of ~17,000 Kakuma households with 23 variables |
| `2-_KAKUMA_DIFFERENTIATED_ASSISTANCE.ipynb` | Python/Jupyter notebook for EDA, statistical analysis, and visualization |
| `3-_KAKUMA_REFUGEE_CAMP___DIFFERENTIATED_ASSISTANCE_ANALYSIS.sql` | Full SQL analysis covering 30 questions across 6 thematic sections |
| `4-_KAKUMA_REFUGEE_CAMP_DIFFRANCE_ASSITANT.pbix` | Power BI dashboard with three interactive report pages |

---

##  Dataset Description

- **Source:** Synthetic dataset modeled on Kakuma Refugee Camp demographics
- **Records:** ~17,000 households (N = 16,811 cleaned)
- **Format:** CSV

### Key Variables

| Variable | Description |
|----------|-------------|
| `Household_ID` | Unique household identifier |
| `Vulnerability_Category` | Vulnerability tier (1 = Most Vulnerable → 4 = Least Vulnerable) |
| `Household_Size` | Number of household members |
| `Dependency_Ratio` | Ratio of dependents to working-age members |
| `Primary_Income_Source` | Aid, Agriculture, Business, Casual Labor, Trading |
| `Employment_Status` | Employed / Self-Employed / Unemployed |
| `Monthly_Income` | Household monthly income |
| `Food_Assistance_Received` | Value of food assistance received |
| `Cash_Assistance_Received` | Value of cash assistance received |
| `Total_Assistance_Value` | Combined assistance value |
| `Monthly_Expenditure` | Total monthly household expenditure |
| `Current_Debt_Level` | Outstanding debt |
| `Debt_Status` | Low / Medium / High |
| `Food_Consumption_Score` | WFP food consumption score |
| `Food_Security_Status` | Insecure / Moderate / Secure |
| `Head_of_Household_Gender` | Male / Female |
| `Female_Headed_Household` | Yes / No |
| `Disability_In_Household` | Yes / No |
| `Chronic_Illness_In_Household` | Yes / No |
| `Elderly_Members_Count` | Number of elderly members |
| `Children_Under_5_Count` | Number of children under 5 |
| `Years_In_Camp` | Duration of residency in camp |

---

##  SQL Analysis

**File:** `3-_KAKUMA_REFUGEE_CAMP___DIFFERENTIATED_ASSISTANCE_ANALYSIS.sql`  
**Database:** SQLite | **Table:** `kakuma_cleaned`

The SQL script covers **30 analytical questions** across **6 thematic sections:**

| Section | Focus |
|---------|-------|
| A: Distribution & Targeting | Household distribution, average assistance per category, proportionality |
| B: Assistance vs Debt | Relationship between debt levels and assistance received |
| C: Food Security | Food consumption scores, security status by vulnerability |
| D: Income & Livelihoods | Income sources, employment status, income-expenditure gaps |
| E: Demographic Vulnerability | Gender, disability, chronic illness, children under 5, elderly |
| F: Economic Resilience | Debt-to-income ratios, expenditure patterns, resilience indicators |

---

##  Python / Jupyter Notebook

**File:** `2-_KAKUMA_DIFFERENTIATED_ASSISTANCE.ipynb`

Covers exploratory data analysis (EDA), statistical summaries, and visualizations including:

- Vulnerability category distributions
- Assistance proportionality testing
- Food security by vulnerability and gender
- Income vs expenditure gap analysis
- Debt burden and economic resilience metrics
- Correlation analysis across key variables

**Libraries used:** `pandas`, `numpy`, `matplotlib`, `seaborn`

---

##  Power BI Dashboard

**File:** `4-_KAKUMA_REFUGEE_CAMP_DIFFRANCE_ASSITANT.pbix`

The dashboard contains **3 interactive report pages:**

### Page 1 — Vulnerability & Targeting Overview
- **17K** total households | **Avg Assistance: 10.73K** | **33% Food Insecure**
- Household distribution by vulnerability category (donut chart)
- Food security status by vulnerability category
- Average assistance by category
- Income vs assistance scatter analysis

### Page 2 — Debt, Income & Economic Resilience
- **Avg Debt: 5.08K** | **Avg Income: 4.29K** | **Debt-to-Income: 1.18** | **33% High Debt**
- Debt status distribution by vulnerability category
- Income vs debt level by employment status (Self-Employed / Employed / Unemployed)
- Expenditure vs income gap by income source (Casual Labor, Agriculture, Trading, Aid, Business)

### Page 3 — Household Vulnerability Deep Dive
- **Food Consumption Score: 723.59K** | **Total HH Size: 101K** | **Assistance per Member: 1.78K**
- Years in camp distribution by vulnerability category
- Camp-wide food consumption score vs WFP threshold gauge
- Primary income sources by vulnerability category
- Total assistance by category and household gender
- Vulnerability intersections table (Female-headed households × vulnerability × FCS)

**Navigation:** Each page includes tab filters for Gender, Vulnerability Category, Employment Status, and Food Security Status.

---

##  Key Findings

- **Targeting Gap:** Assistance is not fully inversely proportional to vulnerability — higher vulnerability categories (1 & 2) do not consistently receive significantly more support than lower categories (3 & 4).
- **Debt Crisis:** Average debt (5.08K) exceeds average monthly income (4.29K), giving a debt-to-income ratio of **1.18** — indicating widespread financial stress.
- **Food Insecurity:** 33% of households are food insecure, with the gap between actual food consumption scores and WFP thresholds concentrated in high-vulnerability households.
- **Gender Disparity:** Female-headed households in vulnerability category 1 receive notably lower average assistance (5,168 KES) compared to category 4 (17,217 KES), suggesting both vulnerability and gender intersect in assistance gaps.
- **Income-Expenditure Gap:** Households relying on Aid and Casual Labor show the widest expenditure-income gaps, with Business being the only income source approaching expenditure parity.

---

## 🚀 How to Use

### SQL
```sql
-- Connect to SQLite database
-- Run 3-_KAKUMA_REFUGEE_CAMP___DIFFERENTIATED_ASSISTANCE_ANALYSIS.sql
-- Table: kakuma_cleaned
```

### Python
```bash
# Install dependencies
pip install pandas numpy matplotlib seaborn jupyter

# Launch notebook
jupyter notebook "2-_KAKUMA_DIFFERENTIATED_ASSISTANCE.ipynb"
```

### Power BI
1. Open `4-_KAKUMA_REFUGEE_CAMP_DIFFRANCE_ASSITANT.pbix` in Power BI Desktop
2. If prompted, update the data source path to point to the CSV file
3. Use the tab navigation (Overview / Debt / Deep Dive) to explore each page
4. Apply slicers for Gender, Vulnerability Category, and Employment Status

---

## Context

**Kakuma Refugee Camp** is one of the world's largest refugee camps, located in Turkana County, northwestern Kenya. Managed by UNHCR and WFP, it hosts refugees primarily from South Sudan, Somalia, DRC, Ethiopia, and Burundi. Differentiated assistance refers to targeting humanitarian aid based on household vulnerability levels to ensure the most at-risk populations receive proportionally greater support.

---

##  Author
**Name:** Olara Anthony Bulu
**Project:** Kakuma Refugee Camp — Differentiated Assistance Analysis  
**Tools:** Python · SQL (SQLite) · Power BI  
**Data:** Synthetic dataset (~17,000 households, 23 variables)

---

*This project uses a synthetic dataset modeled on real-world humanitarian data for analytical and educational purposes.*
