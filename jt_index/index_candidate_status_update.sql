#standardSQL
SELECT 
    ROW_NUMBER() OVER() AS id,
    *
FROM (
  SELECT DISTINCT 
    *
  FROM
    `wagon-jobteaser.raw_candidate_status_update`
)
