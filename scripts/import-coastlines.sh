#/bin/sh

# TODO: simplified water polygons

set -e

DATADIR=../data
[ ! -d $DATADIR ] && mkdir $DATADIR
cd $DATADIR

echo 'Downloading Mercator Water Polygons from http://openstreetmapdata.com/data/water-polygons'
wget http://data.openstreetmapdata.com/water-polygons-split-3857.zip
#wget http://data.openstreetmapdata.com/water-polygons-generalized-3857.zip

echo 'Unpacking and deleting .zip files'
unzip water-polygons-split-3857.zip
rm water-polygons-split-3857.zip
#unzip water-polygons-generalized-3857.zip
#rm water-polygons-generalized-3857.zip

echo 'Importing shapefiles'
shp2pgsql -g way water-polygons-split-3857/water_polygons.shp | psql gis
#shp2pgsql -g way simplified_land_polygons.shp water_polygons_low | psql gis

echo 'Adding indexes to imported data'
cat "$( dirname "${BASH_SOURCE[0]}" )"/../sql/water-indexes.sql | psql gis

