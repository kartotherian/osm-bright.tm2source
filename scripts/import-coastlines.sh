#/bin/sh

shp2pgsql water_polygons.shp | psql gis
shp2pgsql simplified_land_polygons.shp water_polygons_low | psql gis
cat osm2pgsql-osm-bright.tm2source/water-indexes.sql | psql gis

