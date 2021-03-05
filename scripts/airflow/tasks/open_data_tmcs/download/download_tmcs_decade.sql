COPY (
  SELECT *
  FROM open_data.tmcs_joined
  WHERE date_part('year', count_date) >= :yearStart
  AND date_part('year', count_date) <= :yearEnd
) TO stdout WITH (FORMAT csv, HEADER true, ENCODING 'UTF-8');
