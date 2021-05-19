CREATE OR REPLACE FUNCTION public.layer_transportation_name(bbox geometry, zoom_level integer)
    RETURNS TABLE(osm_id bigint, shield text, geometry geometry, name text, name_ text, class text, z_order integer, is text, ref text, reflen integer, len numeric)
    LANGUAGE 'sql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
  SELECT
    *
  FROM
    (
      SELECT
          osm_id,
          'default' AS shield,
          way,
          name,
          (hstore_to_json(extract_names(tags)))::text name_,
          layer_transportation_name_to_class(highway, railway, access, osm_id) AS class,
          z_order,
          CASE
            -- maybe handle all these cases at the data import?
            WHEN bridge IS NOT NULL AND bridge <> '' AND bridge <> 'no' AND bridge <> '0' THEN 'bridge'
            WHEN tunnel IS NOT NULL AND tunnel <> '' AND tunnel <> 'no' AND tunnel <> '0' THEN 'tunnel'
            ELSE 'road'
          END AS "is",
          ref,
          pg_catalog.char_length(ref) AS reflen,
          ROUND(Merc_Length(way)) AS len
        FROM
          planet_osm_line AS osm_line
        WHERE
          (
              (
                highway IN (
                    'motorway', 'primary', 'primary_link', 'trunk',
                    'trunk_link', 'secondary', 'secondary_link'
                  )
                AND (
                  (name IS NOT NULL AND name <> '') OR (ref IS NOT NULL AND ref <> '')
                )
                AND zoom_level >= 11
              )
              OR
              ( -- 'main'
                highway IN (
                    'tertiary', 'tertiary_link', 'residential', 'unclassified',
                    'living_street', 'pedestrian', 'construction', 'rail', 'monorail',
                    'narrow_gauge', 'subway', 'tram'
                  )
                AND (name IS NOT NULL AND name <> '')
                AND zoom_level >= 12
              )
              OR
              ( -- 'motorway_link'
                highway IN (
                    'motorway_link', 'service', 'track', 'driveway', 'path',
                    'cycleway', 'ski', 'steps', 'bridleway', 'footway', 'funicular',
                    'light_rail', 'preserved'
                  )
                AND (name IS NOT NULL AND name <> '')
                AND zoom_level >= 14
              )
          )
          AND
            way && bbox
      ) AS transportation
    ORDER BY
      layer_transportation_priority_score(class, "is", z_order)
  ;
$BODY$;
