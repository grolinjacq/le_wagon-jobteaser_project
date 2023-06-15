SELECT  
 COUNT(id) AS optin
 , COUNT(CASE WHEN optin_qualified_start IS NOT NULL THEN 1 END) AS optin_qualified
 , COUNT(CASE WHEN shortlist_id IS NOT NULL THEN 1 END) AS shortlisted
 , SUM(count_interested) AS interested
 , SUM(count_approved) AS approved
 , SUM(count_not_interested) AS not_interested
 , SUM(count_declined) AS declined
FROM `wagon-jobteaser.jt_transformed.funnel`