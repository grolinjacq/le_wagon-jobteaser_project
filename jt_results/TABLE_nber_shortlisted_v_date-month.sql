SELECT 
    FORMAT_TIMESTAMP('%Y-%m', receive_time) AS month,
    COUNT(CASE WHEN status_update = "awaiting" THEN 1 END) +
    COUNT(CASE WHEN status_update = "interested" THEN 1 END) + 
    COUNT(CASE WHEN status_update = "not_interested" THEN 1 END) AS shortlisted
FROM 
    `wagon-jobteaser.jt_cleaned.clean_candidate_status_update`
GROUP BY 
    month
ORDER BY 
    month;