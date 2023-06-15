SELECT 
* 
FROM `wagon-jobteaser.index_candidate_status_update`
WHERE 
  ID NOT IN (SELECT ID FROM `wagon-jobteaser.jt_ids_to_delete.CAND-A1-1`)
  AND
  ID NOT IN (SELECT ID FROM `wagon-jobteaser.jt_ids_to_delete.CAND-A2-1`)
  AND
  ID NOT IN (SELECT ID FROM `wagon-jobteaser.jt_ids_to_delete.CAND-A3-1`)
ORDER BY receive_time ASC;
