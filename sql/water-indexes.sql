-- This script adds spatial indexes to water_polygons and water_polygons_low
-- It is run by import-coastlines.sh

CREATE INDEX water_polygons_index
  ON water_polygons
  USING gist
  (way)
  WITH (FILLFACTOR=100);

/*CREATE INDEX water_polygons_low_index
  ON water_polygons_low
  USING gist
  (way)
  WITH (FILLFACTOR=100);
*/

