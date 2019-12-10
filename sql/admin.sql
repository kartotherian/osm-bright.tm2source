-- Creates and populates the admin table that stores administrative borders with a
-- precalculated maritime flag. Because admin lines aren't necessarily delimited on
-- water boundaries, split them so that every piece is either only over water or land

CREATE TABLE IF NOT EXISTS admin (LIKE planet_osm_roads INCLUDING ALL);

--
-- Populates admin table. Slow, so run only sparingly in a cronjob. To avoid lock that will
-- make tilerator crash (T204047), a second table is created to store new data and then it 
-- replaces the old admin table
--
CREATE OR REPLACE FUNCTION populate_admin() RETURNS void AS
$$
DECLARE
	row planet_osm_roads%rowtype;
	way geometry;
	water geometry;
	result geometry;
	len int;
BEGIN

	CREATE TABLE admin_new (LIKE planet_osm_roads INCLUDING ALL);

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
	DROP TABLE admin;
	ALTER TABLE admin_new RENAME TO admin;
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
	result geometry;
BEGIN
	SELECT pg_catalog.array_agg(way) INTO water FROM water_polygons WHERE way && geom AND way IS NOT NULL AND geom IS NOT NULL;
	result := ST_Union(water);
	IF GeometryType(result) = 'GEOMETRYCOLLECTION' THEN
		RETURN ST_CollectionExtract(result, 2); -- Extract only linestrings from resulted GeometryCollection
	ELSE
		RETURN result;
	END IF;
END
$$
LANGUAGE plpgsql;


--
-- Inserts 1 row per sub-geometry into the new admin table
--
-- @param row planet_osm_roads: Row to insert
-- @param LineString|MultiLineString geom: Geometry to set for this row
-- @param bool maritime: Whether the border is maritime
--
CREATE OR REPLACE FUNCTION insert_admin_rows(theRow planet_osm_roads, geom geometry, maritime bool) RETURNS void AS
$$
DECLARE
	i int;
BEGIN
	theRow.tags := theRow.tags || (CASE WHEN maritime THEN '"maritime" => "1"' ELSE '"maritime" => "0"' END)::hstore;
	IF GeometryType(geom) = 'LINESTRING' THEN -- Simple geometry
		PERFORM insert_admin_row(theRow, geom);
	ELSE
		FOR i IN 1..ST_NumGeometries(geom) LOOP -- Composite geometry, insert one row per subgeometry
			IF GeometryType(ST_GeometryN(geom, i)) = 'LINESTRING' THEN -- Ensure geometry has the type LINESTRING
				PERFORM insert_admin_row(theRow, ST_GeometryN(geom, i));
			END IF;
		END LOOP;
	END IF;
END
$$
LANGUAGE plpgsql;

--
-- Inserts one row into the new admin table
--
-- @param row theRow: Row to insert
-- @param LineString geom: Geometry to set for this row
--
CREATE OR REPLACE FUNCTION insert_admin_row(theRow planet_osm_roads, geom geometry(LineString)) RETURNS void AS
$$
BEGIN
	theRow.way := geom;
	INSERT INTO admin_new VALUES(theRow.*);
END
$$
LANGUAGE plpgsql;

-- Then populate with:
-- SELECT populate_admin();
