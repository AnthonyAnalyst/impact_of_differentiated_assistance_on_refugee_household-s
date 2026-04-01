/*============================================================
KAKUMA REFUGEE CAMP — DIFFERENTIATED ASSISTANCE ANALYSIS
Full SQL Analysis | N = 16,811 Households
Database: SQLite  |  Table: kakuma
Covers 30 analytical questions across 6 sections
===================================================================*/

-- Exploring data our Dataset
USE differentiated_assistance;
SELECT *
FROM kakuma_cleaned;

-- ============================================================
-- SECTION A: DISTRIBUTION & TARGETING (Q1–Q5)
-- ============================================================

-- Q1: What percentage of households fall into each vulnerability category?
SELECT
    Vulnerability_Category AS Category,
    COUNT(*)               AS Households,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)    AS Pct_of_Total
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Vulnerability_Category;

-- Q2: Average food, cash, and total assistance per category

SELECT
    Vulnerability_Category                    AS Category,
    ROUND(AVG(Food_Assistance_Received), 2)   AS Avg_Food_Assistance,
    ROUND(AVG(Cash_Assistance_Received), 2)   AS Avg_Cash_Assistance,
    ROUND(AVG(Total_Assistance_Value),   2)   AS Avg_Total_Assistance
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Vulnerability_Category;

-- Q3: Is assistance proportional to vulnerability? (ratio vs Cat1 baseline)

WITH base AS (
    SELECT Vulnerability_Category,
           ROUND(AVG(Total_Assistance_Value), 2) AS Avg_Total
    FROM kakuma_cleaned
    GROUP BY Vulnerability_Category
),
cat1_val AS (SELECT Avg_Total FROM base WHERE Vulnerability_Category = 1)
SELECT
    b.Vulnerability_Category AS Category,
    b.Avg_Total,
    ROUND(b.Avg_Total / c.Avg_Total, 2)  AS Ratio_vs_Cat1,
    CASE WHEN b.Avg_Total > LAG(b.Avg_Total) OVER (ORDER BY b.Vulnerability_Category)
         THEN 'INCREASES (inverted)' ELSE 'Decreases (correct)' END AS Direction
FROM base b, cat1_val c
ORDER BY b.Vulnerability_Category;

-- Q4: Do Categories 1 & 2 receive more support than 3 & 4?

SELECT
    CASE WHEN Vulnerability_Category IN (1,2)
         THEN 'Cat 1 & 2 (High Vulnerability)'
         ELSE 'Cat 3 & 4 (Lower Vulnerability)' END  AS Group_,
    COUNT(*)                              AS Households,
    ROUND(AVG(Total_Assistance_Value), 2) AS Avg_Total_Assistance,
    ROUND(MIN(Total_Assistance_Value), 2) AS Min_Assistance,
    ROUND(MAX(Total_Assistance_Value), 2) AS Max_Assistance
FROM kakuma_cleaned
GROUP BY Group_
ORDER BY Group_;

-- Q5: Intra-category inequality (Standard Deviation within each group)

SELECT
    Vulnerability_Category AS Category,
    ROUND(AVG(Total_Assistance_Value), 2) AS Avg_Assistance,
    ROUND(STDDEV_POP(Total_Assistance_Value), 2) AS Std_Dev
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Vulnerability_Category;

-- =====================================================================
-- SECTION B: ASSISTANCE vs DEBT (Q6–Q10)
-- =====================================================================

-- Q6: Average debt level per category
SELECT
    Vulnerability_Category            AS Category,
    ROUND(AVG(Current_Debt_Level), 2) AS Avg_Debt,
    ROUND(MIN(Current_Debt_Level), 2) AS Min_Debt,
    ROUND(MAX(Current_Debt_Level), 2) AS Max_Debt
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Vulnerability_Category;

-- RESULT: Debt is nearly identical across all cats (KES 5,042–5,117) — no differentiation

-- Q7: Percentage of high-debt households per category (ranked)

SELECT
    Vulnerability_Category  AS Category,
    COUNT(*)                AS Total_HH,
    SUM(CASE WHEN Debt_Status = 'High' THEN 1 ELSE 0 END)  AS High_Debt_HH,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status = 'High' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                       AS Pct_High_Debt
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Pct_High_Debt DESC;

-- Q8: Full debt status breakdown (High / Medium / Low) per category

SELECT
    Vulnerability_Category    AS Category,
    Debt_Status,
    COUNT(*)                  AS Count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Vulnerability_Category), 2)
                                                                               AS Pct_Within_Category
FROM kakuma_cleaned
GROUP BY Vulnerability_Category, Debt_Status
ORDER BY Vulnerability_Category, Debt_Status;

-- Q9: Do lower-assistance households have higher debt? (quartile analysis)

WITH deciled AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY Total_Assistance_Value) AS Assistance_Quartile
    FROM kakuma_cleaned
)
SELECT
    Assistance_Quartile,
    ROUND(AVG(Total_Assistance_Value), 0)    AS Avg_Assistance,
    ROUND(AVG(Current_Debt_Level), 0)        AS Avg_Debt,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)
          / COUNT(*), 2)      AS Pct_High_Debt
FROM deciled
GROUP BY Assistance_Quartile
ORDER BY Assistance_Quartile;

-- Q10: Income vs Assistance — which drives debt more? (income quartile analysis)

WITH deciled AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY Monthly_Income) AS Income_Quartile
    FROM kakuma_cleaned WHERE Monthly_Income IS NOT NULL
)
SELECT
    Income_Quartile,
    ROUND(AVG(Monthly_Income), 0)          AS Avg_Income,
    ROUND(AVG(Current_Debt_Level), 0)      AS Avg_Debt,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)
          / COUNT(*), 2)         AS Pct_High_Debt
FROM deciled
GROUP BY Income_Quartile
ORDER BY Income_Quartile;

-- ============================================================
-- SECTION C: ASSISTANCE vs FOOD SECURITY (Q11–Q15)
-- ============================================================

-- Q11: Average Food Consumption Score per category + WFP classification
SELECT
    Vulnerability_Category                      AS Category,
    ROUND(AVG(Food_Consumption_Score), 2)     AS Avg_FCS,
    CASE
        WHEN AVG(Food_Consumption_Score) < 28  THEN 'POOR'
        WHEN AVG(Food_Consumption_Score) < 42  THEN 'BORDERLINE'
        ELSE         'ACCEPTABLE/GOOD'
    END            AS FCS_Classification
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Vulnerability_Category;

-- RESULT: Cat1=16.0 (POOR), Cat2=30.4 (BORDERLINE), Cat3=50.2 (OK), Cat4=74.5 (GOOD)

-- Q12: Percentage food insecure households per category
SELECT
    Vulnerability_Category                                                          AS Category,
    COUNT(*)                                                                        AS Total_HH,
    SUM(CASE WHEN Food_Security_Status = 'Insecure' THEN 1 ELSE 0 END)             AS Insecure_HH,
    ROUND(100.0 * SUM(CASE WHEN Food_Security_Status = 'Insecure' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                                            AS Pct_Insecure
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Vulnerability_Category;
-- Q13: Full food security status breakdown per category

SELECT
    Vulnerability_Category                                                         AS Category,
    Food_Security_Status,
    COUNT(*)                                                                       AS Count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Vulnerability_Category), 2)
                                                                                   AS Pct_Within_Cat
FROM kakuma_cleaned
GROUP BY Vulnerability_Category, Food_Security_Status
ORDER BY Vulnerability_Category, Food_Security_Status;

-- Q14: Does higher assistance improve food security? (assistance quartile analysis)
WITH quartiled AS (
    SELECT *, NTILE(4) OVER (ORDER BY Total_Assistance_Value) AS Assist_Q
    FROM kakuma_cleaned
)
SELECT
    Assist_Q                                                                       AS Assistance_Quartile,
    ROUND(AVG(Total_Assistance_Value), 0)                                          AS Avg_Assistance,
    ROUND(AVG(Food_Consumption_Score), 2)                                          AS Avg_FCS,
    ROUND(100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                                           AS Pct_Food_Insecure
FROM quartiled
GROUP BY Assist_Q
ORDER BY Assist_Q;

-- Q15: Households receiving assistance but still food insecure

SELECT
    COUNT(*)                                             AS Total_HH,
    SUM(CASE WHEN Total_Assistance_Value > 0
             AND Food_Security_Status = 'Insecure'
             THEN 1 ELSE 0 END)                          AS Assisted_But_Insecure,
    ROUND(100.0 * SUM(CASE WHEN Total_Assistance_Value > 0
             AND Food_Security_Status = 'Insecure' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                 AS Pct_of_All_HH,
    ROUND(100.0 * SUM(CASE WHEN Total_Assistance_Value > 0
             AND Food_Security_Status = 'Insecure' THEN 1 ELSE 0 END)
          / NULLIF(SUM(CASE WHEN Total_Assistance_Value > 0 THEN 1 ELSE 0 END), 0), 2)
														 AS Pct_of_Assisted_HH
FROM kakuma_cleaned;

-- ============================================================
-- SECTION D: AT-RISK IDENTIFICATION (Q16–Q19)
-- ============================================================

-- Q16: Composite risk score per category (ranked highest first)
SELECT
    Vulnerability_Category                                                             AS Category,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                                               AS Pct_High_Debt,
    ROUND(100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                                               AS Pct_Food_Insecure,
    ROUND(
        100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END) / COUNT(*) +
        100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END) / COUNT(*),
    2)                                                                                 AS Composite_Risk_Score
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Composite_Risk_Score DESC;

-- Q17: Cat1 vs Cat2 side-by-side comparison
SELECT
    Vulnerability_Category                                                             AS Category,
    ROUND(AVG(Food_Consumption_Score), 2)                                              AS Avg_FCS,
    ROUND(AVG(Current_Debt_Level), 0)                                                  AS Avg_Debt,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)/COUNT(*), 2)    AS Pct_High_Debt,
    ROUND(100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END)/COUNT(*), 2)
                                                                                       AS Pct_Food_Insecure,
    ROUND(AVG(Total_Assistance_Value), 0)                                              AS Avg_Assistance
FROM kakuma_cleaned
WHERE Vulnerability_Category IN (1, 2)
GROUP BY Vulnerability_Category
ORDER BY Vulnerability_Category;

-- Q18: Cat3 households with outcomes worse than Cat2 

WITH cat2_avg AS (
    SELECT 
        AVG(Current_Debt_Level)     AS avg_debt,
        AVG(Food_Consumption_Score) AS avg_fcs
    FROM kakuma_cleaned
    WHERE Vulnerability_Category = 2
)

SELECT
    'Cat3 HH with debt > Cat2 average' AS Metric,
    COUNT(*) AS Count,
    ROUND(100.0 * COUNT(*) /
          (SELECT COUNT(*) FROM kakuma_cleaned WHERE Vulnerability_Category = 3), 2) AS Pct
FROM kakuma_cleaned, cat2_avg
WHERE Vulnerability_Category = 3 
  AND Current_Debt_Level > avg_debt

UNION ALL

SELECT
    'Cat3 HH with FCS < Cat2 average' AS Metric,
    COUNT(*) AS Count,
    ROUND(100.0 * COUNT(*) /
          (SELECT COUNT(*) FROM kakuma_cleaned WHERE Vulnerability_Category = 3), 2) AS Pct
FROM kakuma_cleaned, cat2_avg
WHERE Vulnerability_Category = 3 
  AND Food_Consumption_Score < avg_fcs;
  
  -- Q19: Full matrix — does model cause unintended hardship in Cat3/4?
  
SELECT
    Vulnerability_Category                                  AS Category,
    ROUND(AVG(Total_Assistance_Value), 0)                   AS Avg_Assistance,
    ROUND(AVG(Monthly_Income), 0)                           AS Avg_Income,
    ROUND(AVG(Monthly_Expenditure), 0)                      AS Avg_Expenditure,
    ROUND(AVG(Current_Debt_Level), 0)                       AS Avg_Debt,
    ROUND(AVG(Food_Consumption_Score), 2)                   AS Avg_FCS,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                    AS Pct_High_Debt
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Vulnerability_Category;


-- ============================================================
-- SECTION E: SOCIAL & DEMOGRAPHIC RISK (Q20–Q24)
-- ============================================================

-- Q20: Female-headed vs male-headed household outcomes

SELECT
    Female_Headed_Household                                                            AS Female_Headed,
    COUNT(*)                                                                           AS Total_HH,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)/COUNT(*), 2)   AS Pct_High_Debt,
    ROUND(100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END)/COUNT(*), 2)
                                                                                       AS Pct_Food_Insecure,
    ROUND(AVG(Current_Debt_Level), 0)                                                  AS Avg_Debt,
    ROUND(AVG(Food_Consumption_Score), 2)                                              AS Avg_FCS
FROM kakuma_cleaned
GROUP BY Female_Headed_Household
ORDER BY Female_Headed_Household;

-- Q21: Disability in household vs debt and food insecurity
SELECT
    Disability_In_Household                                                            AS Has_Disability,
    COUNT(*)                                                                           AS Total_HH,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)/COUNT(*), 2)   AS Pct_High_Debt,
    ROUND(AVG(Current_Debt_Level), 0)                                                  AS Avg_Debt,
    ROUND(100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END)/COUNT(*), 2)
                                                                                       AS Pct_Food_Insecure,
    ROUND(AVG(Food_Consumption_Score), 2)                                              AS Avg_FCS
FROM kakuma_cleaned
GROUP BY Disability_In_Household
ORDER BY Disability_In_Household;

-- Q22: Dependency ratio quartiles vs debt and food security

WITH quartiled AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY Dependency_Ratio) AS Dep_Q
    FROM kakuma_cleaned
)
SELECT
    Dep_Q                                                                              AS Dep_Ratio_Quartile,
    ROUND(AVG(Dependency_Ratio), 2)                                                    AS Avg_Dep_Ratio,
    ROUND(AVG(Current_Debt_Level), 0)                                                  AS Avg_Debt,
    ROUND(AVG(Food_Consumption_Score), 2)                                              AS Avg_FCS,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)/COUNT(*), 2)   AS Pct_High_Debt
FROM quartiled
GROUP BY Dep_Q
ORDER BY Dep_Q;


-- Q23: Household size quartiles vs financial stress
WITH quartiled AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY Household_Size) AS HH_Q
    FROM kakuma_cleaned
)
SELECT
    HH_Q                                                                               AS HH_Size_Quartile,
    ROUND(AVG(Household_Size), 1)                                                      AS Avg_HH_Size,
    ROUND(AVG(Current_Debt_Level), 0)                                                  AS Avg_Debt,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)/COUNT(*), 2)   AS Pct_High_Debt,
    ROUND(AVG(Food_Consumption_Score), 2)                                              AS Avg_FCS
FROM quartiled
GROUP BY HH_Q
ORDER BY HH_Q;

-- Q24: Elderly-headed households (60+) vs non-elderly
SELECT
    CASE WHEN Head_of_Household_Age >= 60
         THEN 'Elderly Head (60+)' ELSE 'Non-Elderly Head' END                        AS HoH_Age_Group,
    COUNT(*)                                                                           AS Total_HH,
    ROUND(AVG(Head_of_Household_Age), 1)                                               AS Avg_HoH_Age,
    ROUND(AVG(Current_Debt_Level), 0)                                                  AS Avg_Debt,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)/COUNT(*), 2)   AS Pct_High_Debt,
    ROUND(AVG(Food_Consumption_Score), 2)                                              AS Avg_FCS
FROM kakuma_cleaned
WHERE Head_of_Household_Age IS NOT NULL
GROUP BY HoH_Age_Group
ORDER BY HoH_Age_Group;


-- ============================================================
-- SECTION F: SYSTEM EFFECTIVENESS & POLICY (Q25–Q30)
-- ============================================================

-- Q25: Is the model protecting Cat1? Net monthly balance analysis
SELECT
    Vulnerability_Category                                                             AS Category,
    ROUND(AVG(Total_Assistance_Value), 0)                                              AS Avg_Assistance,
    ROUND(AVG(Monthly_Income), 0)                                                      AS Avg_Income,
    ROUND(AVG(Monthly_Expenditure), 0)                                                 AS Avg_Expenditure,
    ROUND(AVG(Total_Assistance_Value) + AVG(Monthly_Income) - AVG(Monthly_Expenditure), 0)
                                                                                       AS Net_Monthly_Balance,
    ROUND(100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                                               AS Pct_Food_Insecure
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Vulnerability_Category;

-- Q26: Does assistance reduce debt in Cat1? (Cat1 only — quartile analysis)
WITH quartiled AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY Total_Assistance_Value) AS Assist_Q
    FROM kakuma_cleaned WHERE Vulnerability_Category = 1
)
SELECT
    Assist_Q                                                                           AS Assistance_Quartile,
    ROUND(AVG(Total_Assistance_Value), 0)                                              AS Avg_Assistance,
    ROUND(AVG(Current_Debt_Level), 0)                                                  AS Avg_Debt,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END)/COUNT(*), 2)   AS Pct_High_Debt
FROM quartiled
GROUP BY Assist_Q
ORDER BY Assist_Q;

-- Q27: Are funding reductions pushing Cat3 into crisis? (benchmark vs Cat1)
WITH thresholds AS (
    SELECT
        AVG(Current_Debt_Level) AS cat1_avg_debt,
        AVG(Food_Consumption_Score) AS cat1_avg_fcs,
        100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END) / COUNT(*) AS cat1_pct_debt
    FROM kakuma_cleaned
    WHERE Vulnerability_Category = 1
)
SELECT
    k.Vulnerability_Category AS Category,
    ROUND(AVG(k.Current_Debt_Level), 0) AS Avg_Debt,
    ROUND(MAX(t.cat1_avg_debt), 0) AS Cat1_Debt_Threshold,
    ROUND(AVG(k.Food_Consumption_Score), 2) AS Avg_FCS,
    ROUND(MAX(t.cat1_avg_fcs), 2) AS Cat1_FCS_Threshold,
    ROUND(100.0 * SUM(CASE WHEN k.Debt_Status='High' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Pct_High_Debt
FROM kakuma_cleaned k
CROSS JOIN thresholds t
GROUP BY k.Vulnerability_Category
ORDER BY k.Vulnerability_Category;

-- Q28: Income vs Assistance — which predicts food security better?

WITH income_q AS (
    SELECT
        NTILE(4) OVER (ORDER BY Monthly_Income)         AS IQ,
        NTILE(4) OVER (ORDER BY Total_Assistance_Value) AS AQ,
        Food_Consumption_Score,
        Food_Security_Status
    FROM kakuma_cleaned WHERE Monthly_Income IS NOT NULL
)
SELECT 'Income Quartile'    AS Predictor,
       IQ                   AS Quartile,
       ROUND(AVG(Food_Consumption_Score), 2) AS Avg_FCS,
       ROUND(100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS Pct_Insecure
FROM income_q GROUP BY IQ
UNION ALL
SELECT 'Assistance Quartile', AQ,
       ROUND(AVG(Food_Consumption_Score), 2),
       ROUND(100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END)
             / COUNT(*), 2)
FROM income_q GROUP BY AQ
ORDER BY Predictor, Quartile;

-- Q29: Does the model promote equity or widen economic gaps?

WITH cat_stats AS (
    SELECT Vulnerability_Category                        AS cat,
           AVG(Total_Assistance_Value)                   AS avg_assist,
           AVG(Monthly_Income)                           AS avg_income,
           AVG(Food_Consumption_Score)                   AS avg_fcs
    FROM kakuma_cleaned GROUP BY Vulnerability_Category
)
SELECT
    cat                                                                          AS Category,
    ROUND(avg_assist, 0)                                                         AS Avg_Assistance,
    ROUND(avg_income, 0)                                                         AS Avg_Income,
    ROUND(avg_assist + avg_income, 0)                                            AS Total_Resources,
    ROUND(avg_fcs, 2)                                                            AS Avg_FCS,
    ROUND((avg_assist + avg_income) /
          (SELECT MIN(avg_assist + avg_income) FROM cat_stats), 2)               AS Resource_Ratio_vs_Poorest
FROM cat_stats
ORDER BY cat;


-- Q30: Full risk dashboard — which category needs most urgent action?

SELECT
    Vulnerability_Category AS Category,
    COUNT(*) AS Total_HH,
    ROUND(AVG(Total_Assistance_Value), 0) AS Avg_Assistance,
    ROUND(AVG(Food_Consumption_Score), 2) AS Avg_FCS,
    CASE
        WHEN AVG(Food_Consumption_Score) < 28 THEN 'POOR'
        WHEN AVG(Food_Consumption_Score) < 42 THEN 'BORDERLINE'
        ELSE 'ACCEPTABLE'
    END AS FCS_Band,
    ROUND(100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Pct_High_Debt,
    ROUND(100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Pct_Food_Insecure,
    ROUND(
        100.0 * SUM(CASE WHEN Debt_Status='High' THEN 1 ELSE 0 END) / COUNT(*) +
        100.0 * SUM(CASE WHEN Food_Security_Status='Insecure' THEN 1 ELSE 0 END) / COUNT(*),
    2) AS Composite_Risk,
    CASE
        WHEN Vulnerability_Category IN (1,2) AND AVG(Total_Assistance_Value) <
             (SELECT AVG(Total_Assistance_Value) 
              FROM kakuma_cleaned 
              WHERE Vulnerability_Category IN (3,4))
        THEN 'CRITICAL — Inverted allocation'
        WHEN Vulnerability_Category = 2 THEN 'HIGH — Highest composite risk'
        ELSE 'MONITOR'
    END AS Policy_Flag
FROM kakuma_cleaned
GROUP BY Vulnerability_Category
ORDER BY Composite_Risk DESC;