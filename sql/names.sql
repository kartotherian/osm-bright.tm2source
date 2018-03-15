CREATE OR REPLACE FUNCTION extract_names (tags hstore)
  RETURNS hstore
  AS
  $$
    SELECT
      hstore(array_agg(key), array_agg(value))
      FROM (
        SELECT
            SUBSTRING(key FROM 6) AS key,
            value
          FROM each(tags)
          WHERE key LIKE 'name:%'
      ) AS s(key, value)
  $$
LANGUAGE SQL
IMMUTABLE
STRICT;

