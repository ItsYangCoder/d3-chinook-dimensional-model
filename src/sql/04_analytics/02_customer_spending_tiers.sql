-- Customer Spending Tiers
-- Analysis uses data-driven thresholds based on spending distribution

/* THRESHOLD DETERMINATION METHODOLOGY:
   Analysis of customer spending distribution revealed:
   - Min: $36.64, Max: $49.62, Mean: $39.47, Median: $37.62
   - P25: $37.62, P75: $39.62, P90: $43.62
   
   Approach: Balanced Thirds (Tertile-based segmentation)
   - Low Tier: < P33 (~$38)
   - Medium Tier: P33 to P67 ($38 - $40)
   - High Tier: > P67 (~$40)
   
   Alternative approaches considered:
   1. Mean-based: Low < $38, Medium $38-$41, High > $41
   2. Tight segmentation: Low < $37.50, Medium $37.50-$40, High > $40
*/

WITH CustomerSpend AS (
    -- Step 1: Calculate total spend per customer
    SELECT 
        customer_id,
        SUM(line_amount) AS total_spend
    FROM 
        workspace.d3_mart.fact_sales
    GROUP BY 
        customer_id
),
SpendingStats AS (
    -- Step 2: Calculate distribution statistics for threshold validation
    SELECT 
        PERCENTILE(total_spend, 0.33) AS p33_threshold,
        PERCENTILE(total_spend, 0.67) AS p67_threshold,
        AVG(total_spend) AS mean_spend,
        PERCENTILE(total_spend, 0.50) AS median_spend
    FROM 
        CustomerSpend
),
TieredCustomers AS (
    -- Step 3: Assign spending tier using balanced-thirds approach
    SELECT 
        cs.customer_id,
        cs.total_spend,
        CASE 
            WHEN cs.total_spend > ss.p67_threshold THEN 'High'
            WHEN cs.total_spend >= ss.p33_threshold THEN 'Medium'
            ELSE 'Low'
        END AS spending_tier,
        ss.p33_threshold,
        ss.p67_threshold,
        ss.mean_spend,
        ss.median_spend
    FROM 
        CustomerSpend cs
    CROSS JOIN 
        SpendingStats ss
)
-- Step 4: Count customers in each tier and show thresholds used
SELECT 
    spending_tier,
    COUNT(customer_id) AS customer_count,
    ROUND(MIN(total_spend), 2) AS min_spend_in_tier,
    ROUND(MAX(total_spend), 2) AS max_spend_in_tier,
    ROUND(AVG(total_spend), 2) AS avg_spend_in_tier,
    ROUND(MAX(p33_threshold), 2) AS p33_threshold_used,
    ROUND(MAX(p67_threshold), 2) AS p67_threshold_used,
    ROUND(MAX(mean_spend), 2) AS overall_mean,
    ROUND(MAX(median_spend), 2) AS overall_median
FROM 
    TieredCustomers
GROUP BY 
    spending_tier
ORDER BY 
    CASE spending_tier 
        WHEN 'High' THEN 1 
        WHEN 'Medium' THEN 2 
        WHEN 'Low' THEN 3 
    END;