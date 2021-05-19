/*
  accepts a transportation name type value and maps the value to a class
*/
CREATE OR REPLACE FUNCTION public.layer_transportation_name_to_class(highway text, railway text, access text, osm_id bigint)
  RETURNS text
AS
  $$
    declare
      class_name text;

    BEGIN
      SELECT
        CASE
          WHEN highway IN ('motorway', 'motorway_link', 'driveway') THEN highway
          WHEN highway IN ('primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'tertiary_link') THEN 'main'
          WHEN highway IN ('residential', 'unclassified', 'living_street') THEN 'street'
          WHEN highway IN ('pedestrian', 'construction') OR access = 'private' THEN 'street_limited'
          WHEN railway IN ('rail', 'monorail', 'narrow_gauge', 'subway', 'tram') THEN 'major_rail'
          WHEN highway IN ('service', 'track') THEN 'service'
          WHEN highway IN ('path', 'cycleway', 'ski', 'steps', 'bridleway', 'footway') THEN 'path'
          WHEN railway IN ('funicular', 'light_rail', 'preserved') THEN 'minor_rail'
          ELSE bail_out('Unexpected road row with osm_id=%s', osm_id::TEXT)
        END INTO class_name
      ;

      RETURN class_name;
    END;
  $$ language 'plpgsql';
