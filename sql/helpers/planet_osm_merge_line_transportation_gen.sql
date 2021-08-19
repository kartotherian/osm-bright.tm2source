-- planet_osm_merge_line_transportation_gen_z11
DROP MATERIALIZED VIEW IF EXISTS planet_osm_merge_line_transportation_gen_z11 CASCADE;
CREATE MATERIALIZED VIEW planet_osm_merge_line_transportation_gen_z11 AS (
  SELECT
    format('%s_%s_%s_%s_%s_%s_%s_%s_%s_%s', tags, aeroway, access, bridge, highway, name, railway, ref, tunnel, waterway) AS id,
    NULL::bigint AS osm_id,
    tags,
    aeroway,
    access,
    bridge,
    highway,
    name,
    railway,
    ref,
    tunnel,
    waterway,
    min(z_order) AS z_order,
    ST_Simplify(
      ST_LineMerge(ST_Collect(way)), ZRes(9)
  ) AS way
  FROM 
    planet_osm_line
  WHERE 
    highway IN ('motorway', 'primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link')
  AND 
    ST_IsValid(way)
  GROUP BY
    tags, aeroway, access, bridge, highway, name, railway, ref, tunnel, waterway
);

CREATE UNIQUE INDEX ON planet_osm_merge_line_transportation_gen_z11 (id); -- necessary for concurrent refresh
CREATE INDEX ON planet_osm_merge_line_transportation_gen_z11 USING gist (way);

-- planet_osm_merge_line_transportation_gen_z10
CREATE MATERIALIZED VIEW planet_osm_merge_line_transportation_gen_z10 AS (
  SELECT
    id,
    osm_id,
    tags,
    aeroway,
    access,
    bridge,
    highway,
    name,
    railway,
    ref,
    tunnel,
    waterway,
    z_order,
    ST_Simplify(way, ZRes(8)) AS way
  FROM 
    planet_osm_merge_line_transportation_gen_z11
);

CREATE UNIQUE INDEX ON planet_osm_merge_line_transportation_gen_z10 (id); -- necessary for concurrent refresh
CREATE INDEX ON planet_osm_merge_line_transportation_gen_z10 USING gist (way);

-- planet_osm_merge_line_transportation_gen_z9
CREATE MATERIALIZED VIEW planet_osm_merge_line_transportation_gen_z9 AS (
  SELECT
    id,
    osm_id,
    tags,
    aeroway,
    access,
    bridge,
    highway,
    name,
    railway,
    ref,
    tunnel,
    waterway,
    z_order,
    ST_Simplify(way, ZRes(7)) AS way
  FROM 
    planet_osm_merge_line_transportation_gen_z10
  WHERE 
    highway IN ('motorway', 'primary', 'primary_link', 'trunk', 'trunk_link')
);

CREATE UNIQUE INDEX ON planet_osm_merge_line_transportation_gen_z9 (id); -- necessary for concurrent refresh
CREATE INDEX ON planet_osm_merge_line_transportation_gen_z9 USING gist (way);

-- planet_osm_merge_line_transportation_gen_z8
CREATE MATERIALIZED VIEW planet_osm_merge_line_transportation_gen_z8 AS (
  SELECT
    id,
    osm_id,
    tags,
    aeroway,
    access,
    bridge,
    highway,
    name,
    railway,
    ref,
    tunnel,
    waterway,
    z_order,
    ST_Simplify(way, ZRes(6)) AS way
  FROM 
    planet_osm_merge_line_transportation_gen_z9
  WHERE 
    highway IN ('motorway', 'primary', 'primary_link', 'trunk', 'trunk_link')
);

CREATE UNIQUE INDEX ON planet_osm_merge_line_transportation_gen_z8 (id); -- necessary for concurrent refresh
CREATE INDEX ON planet_osm_merge_line_transportation_gen_z8 USING gist (way);

-- planet_osm_merge_line_transportation_gen_z7
CREATE MATERIALIZED VIEW planet_osm_merge_line_transportation_gen_z7 AS (
  SELECT
    id,
    osm_id,
    tags,
    aeroway,
    access,
    bridge,
    highway,
    name,
    railway,
    ref,
    tunnel,
    waterway,
    z_order,
    ST_Simplify(way, ZRes(5)) AS way
  FROM 
    planet_osm_merge_line_transportation_gen_z8
  WHERE 
    ST_Length(way) > 50
);

CREATE UNIQUE INDEX ON planet_osm_merge_line_transportation_gen_z7 (id); -- necessary for concurrent refresh
CREATE INDEX ON planet_osm_merge_line_transportation_gen_z7 USING gist (way);

-- planet_osm_merge_line_transportation_gen_z6
CREATE MATERIALIZED VIEW planet_osm_merge_line_transportation_gen_z6 AS (
  SELECT
    id,
    osm_id,
    tags,
    aeroway,
    access,
    bridge,
    highway,
    name,
    railway,
    ref,
    tunnel,
    waterway,
    z_order,
    ST_Simplify(way, ZRes(4)) AS way
  FROM 
    planet_osm_merge_line_transportation_gen_z7
  WHERE 
    ST_Length(way) > 100
);

CREATE UNIQUE INDEX ON planet_osm_merge_line_transportation_gen_z6 (id); -- necessary for concurrent refresh
CREATE INDEX ON planet_osm_merge_line_transportation_gen_z6 USING gist (way);

-- planet_osm_merge_line_transportation_gen_z5
CREATE MATERIALIZED VIEW planet_osm_merge_line_transportation_gen_z5 AS (
  SELECT
    id,
    osm_id,
    tags,
    aeroway,
    access,
    bridge,
    highway,
    name,
    railway,
    ref,
    tunnel,
    waterway,
    z_order,
    ST_Simplify(way, ZRes(3)) AS way
  FROM 
    planet_osm_merge_line_transportation_gen_z6
  WHERE 
    ST_Length(way) > 500
);

CREATE UNIQUE INDEX ON planet_osm_merge_line_transportation_gen_z5 (id); -- necessary for concurrent refresh
CREATE INDEX ON planet_osm_merge_line_transportation_gen_z5 USING gist (way);

-- running this function will cause the above materialized views to refresh CONCURRENTLY. The concurrently 
-- piece is important as without it the refresh would be a blocking operation.
CREATE OR REPLACE FUNCTION refresh_planet_osm_merge_line_transportation_gen() RETURNS void AS
$$
DECLARE
    t TIMESTAMP WITH TIME ZONE := clock_timestamp();
BEGIN
    RAISE LOG 'refreshing_osm_merge_line_transportation_gen_* tables';
    REFRESH MATERIALIZED VIEW CONCURRENTLY planet_osm_merge_line_transportation_gen_z11;
    REFRESH MATERIALIZED VIEW CONCURRENTLY planet_osm_merge_line_transportation_gen_z10;
    REFRESH MATERIALIZED VIEW CONCURRENTLY planet_osm_merge_line_transportation_gen_z9;
    REFRESH MATERIALIZED VIEW CONCURRENTLY planet_osm_merge_line_transportation_gen_z8;
    REFRESH MATERIALIZED VIEW CONCURRENTLY planet_osm_merge_line_transportation_gen_z7;
    REFRESH MATERIALIZED VIEW CONCURRENTLY planet_osm_merge_line_transportation_gen_z6;
    REFRESH MATERIALIZED VIEW CONCURRENTLY planet_osm_merge_line_transportation_gen_z5;

    RAISE LOG 'refreshing_osm_merge_line_transportation_gen_* tables completed in %', age(clock_timestamp(), t);
END;
$$ LANGUAGE plpgsql;
