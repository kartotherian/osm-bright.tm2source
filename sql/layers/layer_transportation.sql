CREATE OR REPLACE FUNCTION public.layer_transportation(bbox geometry, zoom_level integer)
    RETURNS TABLE(osm_id bigint, geometry geometry, class text, z_order integer, is text)
    LANGUAGE 'sql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
  SELECT
    osm_id,
    way,
    class,
    z_order,
    "is"
  FROM (
    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
	    -- maybe handle all these cases at the data import?
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_merge_line_transportation_gen_z5
    WHERE
      zoom_level = 5
    UNION ALL

    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_merge_line_transportation_gen_z6
    WHERE
      zoom_level = 6
    UNION ALL

    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_merge_line_transportation_gen_z7
    WHERE
      zoom_level = 7
    UNION ALL

    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_merge_line_transportation_gen_z8
    WHERE
      zoom_level = 8
    UNION ALL

    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_merge_line_transportation_gen_z9
    WHERE
      zoom_level = 9
    UNION ALL

    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_merge_line_transportation_gen_z10
    WHERE
      zoom_level = 10
    UNION ALL

    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_merge_line_transportation_gen_z11
    WHERE
      zoom_level = 11
    UNION ALL

    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_line
    WHERE
      zoom_level = 12
    UNION ALL

    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_line
    WHERE
      zoom_level = 13
    UNION ALL

    SELECT
      osm_id,
      way,
      layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
      z_order,
      CASE
        WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
        WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
        ELSE 'road'
      END AS "is"
    FROM
      planet_osm_line
    WHERE
      zoom_level >= 14
  ) AS layer_data
  WHERE
    way && bbox
  ORDER BY
    layer_transportation_priority_score(class, "is", z_order)
  ;

$BODY$;
