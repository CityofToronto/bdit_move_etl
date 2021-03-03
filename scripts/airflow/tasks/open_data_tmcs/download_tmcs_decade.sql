COPY (
  SELECT tcd.*
  FROM open_data.tmcs_count_data tcd
  JOIN open_data.tmcs_count_metadata tcm USING (count_id)
  WHERE date_part('year', tcm.count_date) >= :yearStart
  AND date_part('year', tcm.count_date) <= :yearEnd
) TO stdout WITH (FORMAT csv, HEADER true, ENCODING 'UTF-8');
