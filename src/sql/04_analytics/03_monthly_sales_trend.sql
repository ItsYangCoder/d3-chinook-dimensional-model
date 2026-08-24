--To answer How has revenue trended month-by-month over the last 2 years?
SELECT
    DATE_FORMAT(d.full_date, 'yyyy-MM') AS year_month,
    d.year,
    d.month,
    SUM(s.line_amount) AS monthly_revenue
FROM workspace.d3_clean.clean_sales s      --palitan nalang pag may fact_sales na
JOIN workspace.d3_mart.dim_date d
    ON CAST(DATE_FORMAT(s.invoice_date, 'yyyyMMdd') AS INT) = d.date_key
WHERE d.full_date >= DATEADD(YEAR, -2, CURRENT_DATE)
GROUP BY DATE_FORMAT(d.full_date, 'yyyy-MM'),year,month
ORDER BY year_month;

