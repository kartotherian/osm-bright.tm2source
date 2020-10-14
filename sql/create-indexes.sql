--
-- Name: planet_osm_line_index; Type: INDEX; Schema: public; Owner: osmimporter; Tablespace:
--

DO $$
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM   pg_class c
    JOIN   pg_namespace n ON n.oid = c.relnamespace
    WHERE  c.relname = 'planet_osm_line_index'
    AND    n.nspname = 'public'
    ) THEN

	CREATE INDEX planet_osm_line_index ON planet_osm_line USING gist (way);
END IF;

END$$;


--
-- Name: planet_osm_line_pkey; Type: INDEX; Schema: public; Owner: osmimporter; Tablespace:
--

DO $$
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM   pg_class c
    JOIN   pg_namespace n ON n.oid = c.relnamespace
    WHERE  c.relname = 'planet_osm_line_pkey'
    AND    n.nspname = 'public'
    ) THEN

	CREATE INDEX planet_osm_line_pkey ON planet_osm_line USING btree (osm_id);
END IF;

END$$;


--
-- Name: planet_osm_point_index; Type: INDEX; Schema: public; Owner: osmimporter; Tablespace:
--

DO $$
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM   pg_class c
    JOIN   pg_namespace n ON n.oid = c.relnamespace
    WHERE  c.relname = 'planet_osm_point_index'
    AND    n.nspname = 'public'
    ) THEN

	CREATE INDEX planet_osm_point_index ON planet_osm_point USING gist (way);
END IF;

END$$;


--
-- Name: planet_osm_point_pkey; Type: INDEX; Schema: public; Owner: osmimporter; Tablespace:
--

DO $$
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM   pg_class c
    JOIN   pg_namespace n ON n.oid = c.relnamespace
    WHERE  c.relname = 'planet_osm_point_pkey'
    AND    n.nspname = 'public'
    ) THEN

	CREATE INDEX planet_osm_point_pkey ON planet_osm_point USING btree (osm_id);
END IF;

END$$;


--
-- Name: planet_osm_polygon_index; Type: INDEX; Schema: public; Owner: osmimporter; Tablespace:
--

DO $$
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM   pg_class c
    JOIN   pg_namespace n ON n.oid = c.relnamespace
    WHERE  c.relname = 'planet_osm_polygon_index'
    AND    n.nspname = 'public'
    ) THEN

	CREATE INDEX planet_osm_polygon_index ON planet_osm_polygon USING gist (way);
END IF;

END$$;


--
-- Name: planet_osm_polygon_pkey; Type: INDEX; Schema: public; Owner: osmimporter; Tablespace:
--

DO $$
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM   pg_class c
    JOIN   pg_namespace n ON n.oid = c.relnamespace
    WHERE  c.relname = 'planet_osm_polygon_pkey'
    AND    n.nspname = 'public'
    ) THEN

	CREATE INDEX planet_osm_polygon_pkey ON planet_osm_polygon USING btree (osm_id);
END IF;

END$$;

--
-- Name: water_polygons_way_idx; Type: INDEX; Schema: public; Owner: osmimporter; Tablespace:
--

DO $$
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM   pg_class c
    JOIN   pg_namespace n ON n.oid = c.relnamespace
    WHERE  c.relname = 'water_polygons_way_idx'
    AND    n.nspname = 'public'
    ) THEN

	CREATE INDEX water_polygons_way_idx ON water_polygons USING gist (way);
END IF;

END$$;


--
-- Name: planet_osm_polygon_wikidata; Type: INDEX; Schema: public; Owner: osmimporter; Tablespace:
--

DO $$
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM   pg_class c
    JOIN   pg_namespace n ON n.oid = c.relnamespace
    WHERE  c.relname = 'planet_osm_polygon_wikidata'
    AND    n.nspname = 'public'
    ) THEN

	CREATE INDEX planet_osm_polygon_wikidata ON planet_osm_polygon USING btree (((tags -> 'wikidata'::text))) WHERE (tags ? 'wikidata'::text);
END IF;

END$$;

