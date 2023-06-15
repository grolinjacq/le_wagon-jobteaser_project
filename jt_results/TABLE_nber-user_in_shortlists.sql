WITH
    user_per_shortlist AS(
        SELECT 
            shortlist_id
            , COUNT(DISTINCT user_id) AS count_user
        FROM 
            `jt_cleaned.clean_candidate_status_update`
        GROUP BY
            shortlist_id
    )
SELECT
    AVG(count_user)
    , MAX(count_user)
    , MIN(count_user)
FROM user_per_shortlist