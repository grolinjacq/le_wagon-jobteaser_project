WITH 
  funnel6_qual_users_only AS(
    SELECT * 
    FROM `wagon-jobteaser.jt_transformed.funnel`
    WHERE optin_qualified_start IS NOT NULL
    ),
  avg_optin_timeframe AS(
    SELECT
      AVG(optin_timeframe_days) AS avg_days
    FROM funnel6_qual_users_only
    WHERE optin_stop IS NOT NULL
    ),
  replaced_optin_stop AS (
    SELECT
      t.id
      , t.user_id
      , t.optin_start
      , IFNULL(t.optin_stop, TIMESTAMP_ADD(t.optin_start, INTERVAL CAST(avg.avg_days AS INT64) DAY)) AS optin_stop
      , COALESCE(DATE_DIFF(t.optin_stop, t.optin_start, DAY), avg.avg_days) AS optin_timeframe_days
    FROM funnel6_qual_users_only t
    CROSS JOIN avg_optin_timeframe avg
  ),
  dates AS (
    SELECT date
    FROM UNNEST(
      GENERATE_DATE_ARRAY(
        (SELECT DATE_TRUNC(DATE(MIN(optin_start)), MONTH) FROM replaced_optin_stop),
        (SELECT DATE_TRUNC(DATE(MAX(optin_stop)), MONTH) FROM replaced_optin_stop),
        INTERVAL 1 MONTH
      )
    ) AS date
  ), 
  user_month_activity AS (
    SELECT
      d.date,
      t.user_id,
      t.id
    FROM replaced_optin_stop t
    CROSS JOIN dates d
    WHERE d.date BETWEEN DATE_TRUNC(DATE(t.optin_start), MONTH) AND DATE_TRUNC(DATE(t.optin_stop), MONTH)
  )
SELECT
  FORMAT_DATE('%Y-%m', date) as month,
  COUNT(DISTINCT id) as active_users
FROM user_month_activity
GROUP BY month
ORDER BY month