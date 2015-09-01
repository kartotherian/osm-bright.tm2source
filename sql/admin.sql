-- Creates and populates the admin table that stores administrative borders with a
-- precalculated maritime flag. Because admin lines aren't necessarily delimited on
-- water boundaries, split them so that every piece is either only over water or land

CREATE TABLE IF NOT EXISTS admin (LIKE planet_osm_roads);

--
-- Populates admin table. Slow, so run only sparingly in a cronjob
--
CREATE OR REPLACE FUNCTION populate_admin() RETURNS void AS
$$
DECLARE
	row admin%rowtype;
	way geometry;
	water geometry;
	result geometry;
	len int;

BEGIN
	TRUNCATE TABLE admin;

	-- Let the datasource to perform precise filtering, but just don't pull all the crap here
	FOR row IN SELECT * FROM planet_osm_roads WHERE boundary='administrative' AND admin_level IN ('2', '4') LOOP
		way := row.way;
		water := water_under(way);

		IF water IS NULL THEN
			PERFORM insert_admin_rows(row, way, FALSE);
			CONTINUE;
		END IF;

		result := ST_Intersection(way, water);
		

		IF ST_IsEmpty(result) THEN
			PERFORM insert_admin_rows(row, way, FALSE);
		ELSE
			PERFORM insert_admin_rows(row, result, TRUE);

			IF NOT ST_Equals(way, result) THEN
				result := ST_Difference(way, water);
				IF NOT ST_IsEmpty(result) THEN
					PERFORM insert_admin_rows(row, result, FALSE);
				END IF;
			END IF;
		END IF;
	END LOOP;
END
$$
LANGUAGE plpgsql;

--
-- Returns joined water polygons under a given geometry
--
-- @param geometry geom: Geometry to check under
--
CREATE OR REPLACE FUNCTION water_under(geom geometry) RETURNS geometry AS
$$
DECLARE
	water geometry[];

BEGIN
	SELECT array_agg(way) INTO water FROM water_polygons WHERE way && geom AND way IS NOT NULL AND geom IS NOT NULL;
	RETURN ST_Union(water);
END
$$
LANGUAGE plpgsql;


--
-- Inserts 1 row per sub-geometry into the admin table
--
-- @param row admin: Row to insert
-- @param LineString|MultiLineString geom: Geometry to set for this row
-- @param bool maritime: Whether the border is maritime
--
CREATE OR REPLACE FUNCTION insert_admin_rows(theRow admin, geom geometry, maritime bool) RETURNS void AS
$$
DECLARE
	i int;

BEGIN
	theRow.tags := theRow.tags || (CASE WHEN maritime THEN '"maritime" => "1"' ELSE '"maritime" => "0"' END)::hstore;
	IF GeometryType(geom) = 'LINESTRING' THEN -- Simple geometry
		PERFORM insert_admin_row(theRow, geom);
	ELSE
		FOR i IN 1..ST_NumGeometries(geom) LOOP -- Composite geometry, insert one row per subgeometry
			PERFORM insert_admin_row(theRow, ST_GeometryN(geom, i));
		END LOOP;
	END IF;
END
$$
LANGUAGE plpgsql;

--
-- Inserts one row into the admin table
--
-- @param row theRow: Row to insert
-- @param LineString geom: Geometry to set for this row
--
CREATE OR REPLACE FUNCTION insert_admin_row(theRow admin, geom geometry(LineString)) RETURNS void AS
$$
BEGIN
	theRow.way := geom;
	INSERT INTO admin VALUES(theRow.*);
END
$$
LANGUAGE plpgsql;

-- Then populate with:
-- SELECT populate_admin();
