WITH 
  step1 AS (
    -- Step 1: Calculate flags for the start and end of each period
    SELECT 
      *,
      -- Flag for the start of a period
      CASE WHEN active = true AND LAG(active) OVER (PARTITION BY user_id ORDER BY receive_time) IS DISTINCT FROM active THEN 1 ELSE 0 END as start_period_flag,
      -- Flag for the end of a period
      CASE WHEN active = false AND LEAD(active) OVER (PARTITION BY user_id ORDER BY receive_time) IS DISTINCT FROM active THEN 1 ELSE 0 END as end_period_flag
    FROM 
      `wagon-jobteaser.jt_cleaned.clean_optin`
  ),

  step2 AS (
    -- Step 2: Calculate the period number for each record
    SELECT 
      *,
      COALESCE(SUM(start_period_flag) OVER (PARTITION BY user_id ORDER BY receive_time ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) + CASE WHEN start_period_flag = 1 THEN 1 ELSE 0 END AS period_number    
      FROM 
      step1
  ),

  period_starts AS (
    -- Step 3: Identify the start of each period and qualified start if resume uploaded
    SELECT 
      user_id,
      period_number,
      receive_time AS optin_start,
      CASE WHEN resume_uploaded = true THEN receive_time END AS optin_qualified_start
    FROM step2
    WHERE start_period_flag = 1
  ),

  period_ends AS (
    -- Step 4: Identify the end of each period
    SELECT 
      user_id,
      period_number,
      receive_time AS optin_stop
    FROM step2
    WHERE end_period_flag = 1
  ),

  optinperiod_user AS (
    -- Step 5: Join the period start and end records and assign an ID
    SELECT 
      ROW_NUMBER() OVER() AS id,
      period_starts.user_id,
      period_starts.period_number, 
      optin_start,
      optin_qualified_start,
      optin_stop
    FROM 
      period_starts
    LEFT JOIN 
      period_ends ON period_starts.user_id = period_ends.user_id AND period_starts.period_number = period_ends.period_number 
    ORDER BY 
      period_starts.user_id, 
      period_starts.period_number
  ),


  first_status_updates AS (
    SELECT
      user_id,
      shortlist_id,
      MIN(receive_time) AS receive_time
    FROM `wagon-jobteaser.jt_cleaned.clean_candidate_status_update`
    GROUP BY user_id, shortlist_id
  ),

  count_status_update AS (
    -- Step 7: Count the occurrences of each status update for each user_id and shortlist_id
    SELECT DISTINCT
      user_id,
      shortlist_id,
      COUNT(CASE WHEN status_update="awaiting" THEN 1 END) AS count_awaiting,
      COUNT(CASE WHEN status_update="interested" THEN 1 END) AS count_interested,
      COUNT(CASE WHEN status_update="not interested" THEN 1 END) AS count_not_interested,
      COUNT(CASE WHEN status_update="declined" THEN 1 END) AS count_declined,
      COUNT(CASE WHEN status_update="approved" THEN 1 END) AS count_approved
    FROM `wagon-jobteaser.jt_cleaned.clean_candidate_status_update`
    GROUP BY user_id, shortlist_id
  ),

  funnel AS (
    -- Step 8: Build the final funnel data by joining all the previous steps and calculating additional fields
    SELECT DISTINCT
      p.period_number,
      p.user_id,
      fsu.shortlist_id,
      p.optin_start,
      p.optin_qualified_start,
      p.optin_stop,
      DATE_DIFF(IFNULL(p.optin_stop, "2020-11-09 12:43:00 UTC"), p.optin_start, DAY) AS optin_timeframe_days,
      csu.count_awaiting,
      csu.count_interested,
      csu.count_not_interested,
      csu.count_declined,
      csu.count_approved
    FROM optinperiod_user AS p
    LEFT JOIN first_status_updates AS fsu
      ON p.user_id = fsu.user_id 
      AND fsu.receive_time >= p.optin_start 
      AND (fsu.receive_time < p.optin_stop OR p.optin_stop IS NULL)
    LEFT JOIN count_status_update AS csu
      ON p.user_id = csu.user_id
      AND fsu.shortlist_id = csu.shortlist_id
    ORDER BY p.user_id, p.period_number
  )  

-- Step 9: Select the final results with a row number ID
SELECT
  ROW_NUMBER() OVER() AS id,
  *
FROM funnel
WHERE optin_timeframe_days > 0