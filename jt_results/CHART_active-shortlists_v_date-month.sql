SELECT
  FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP(receive_time)) AS month,
  COUNT(DISTINCT shortlist_id) AS active_shortlist_count,
  COUNT(DISTINCT shortlist_id) * 20 AS active_shortlist_maximum_capacity
FROM
  `wagon-jobteaser.jt_cleaned.clean_candidate_status_update`
-- WHERE
--   status_update != 'not interested' -- Exclude 'not interested' status
GROUP BY
  month
ORDER BY
  month