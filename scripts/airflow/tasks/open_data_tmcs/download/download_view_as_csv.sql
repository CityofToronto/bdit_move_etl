COPY (
  SELECT *
  FROM :view
) TO stdout WITH (FORMAT csv, HEADER true, ENCODING 'UTF-8');
