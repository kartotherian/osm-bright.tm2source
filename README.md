# osm-bright.tm2source
Data source for [Kartotherian's fork  of OSM Bright](https://github.com/kartotherian/osm-bright.tm2)

# Install
This style requires an imposm3 database with ocean data, custom indexes, and custom functions.

It's probably easiest to grab an PBF of OSM data from [geofabrik](http://download.geofabrik.de/). Once you've installed PostgreSQL and PostGIS, create a database and import with imposm3:

```sh
createdb gis
psql -d gis -c 'CREATE EXTENSION postgis; CREATE EXTENSION hstore;'
imposm import \
    -config ~/path/to/imposm/config.json \
    -mapping ./imposm_mapping.yml \
    -overwritecache \
    -read ~/path/to/data.osm.pbf \
    -diff \
    -write
imposm import \
    -config ~/path/to/imposm/config.json \
    -deployproduction 
```

Next we need some shapefiles for water_polygons and water_polygons_simplfied

```sh
curl -O http://data.openstreetmapdata.com/water-polygons-split-3857.zip
unzip water-polygons-split-3857.zip && rm water-polygons-split-3857.zip
cd water-polygons-split-3857
shp2pgsql -I -s 3857 -g way water_polygons.shp water_polygons | psql -Xqd gis
```

```sh
curl -O http://data.openstreetmapdata.com/simplified-water-polygons-split-3857.zip
unzip simplified-water-polygons-split-3857.zip && rm simplified-water-polygons-split-3857.zip
cd simplified-water-polygons-split-3857
shp2pgsql -I -s 3857 -g way simplified_water_polygons.shp water_polygons_simplified | psql -Xqd gis
```

Then the custom functions, indexes, and the layers functions

```sh
cd .. # return to osm-bright.tm2source directory
npm install
psql -Xqd gis -f node_modules/@kartotherian/postgis-vt-util/lib.sql
psql -Xqd gis -f sql/helpers/functions.sql
psql -Xqd gis -f sql/helpers/create-indexes.sql
psql -Xqd gis -f sql/helpers/names.sql
for sql_file in ./sql/layers/*.sql; do 
    echo $sql_file;
    psql -Xqd gis -f $sql_file;
done
```

# Editing
* Clone [osm-bright.tm2source](https://github.com/kartotherian/osm-bright.tm2source) repository (this one)
* Install the latest [Mapbox Studio Classic](https://www.mapbox.com/mapbox-studio-classic/)
Open Mapbox Studio and open the data source. You should see your data as "x-ray" outlines. Don't edit just data.yml or data.xml - they must be in sync; editing this project in MBS only ensures that.

To see the data in style
* Clone [osm-bright.tm2](https://github.com/kartotherian/osm-bright.tm2) repository
* Edit style's project.yml - change the `source:` to `"tmsource:///home/user/.../osm-bright.tm2source"` directory.
Open it in the Mapbox Studio.

# Layers
The order of layers in this style matters because that's the default order that they will be drawn on map. Note that the list of layers goes from bottom to top, opposite to the order in files.
* `landuse` - various uses for land: wood, park, industrial zone, etc. Mostly corresponds to OSM's [`landuse` key](http://wiki.openstreetmap.org/wiki/Key:landuse).
* `waterway` - [streams, rivers on low zoom, etc](http://wiki.openstreetmap.org/wiki/Key:waterway).
* `water` - water bodies (oceans, lakes, rivers wide enough on a given zoom level to be represented by areas as opposed to lines).
* `aeroway` - both areas and lines related to airports: [tarmacs, taxiing lines, etc](http://wiki.openstreetmap.org/wiki/Key:aeroway).
* `building` - buildings.
* `road` - roads and other similar transport ways: streets, bridges and tunnels.
* `admin` - [administrative borders](http://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative) between countries and regions.
* `country_label` - country labels.
* `place_label` - city/neighborhood/district labels.
* `poi_label` - places of interest. Currently, only transport stations are implemented.
* `road_label` - road labels, including highway number shields.
