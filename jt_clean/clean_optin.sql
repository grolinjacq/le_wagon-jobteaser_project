SELECT 
* 
FROM `wagon-jobteaser.raw_optin`
WHERE 
  ID NOT IN (SELECT ID FROM `wagon-jobteaser.jt_ids_to_delete.OPTI-A2-1`)
  AND
  ID NOT IN (SELECT ID FROM `wagon-jobteaser.jt_ids_to_delete.OPTI-A3-1`)
ORDER BY receive_time ASC
    
