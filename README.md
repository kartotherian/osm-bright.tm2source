# osm-bright.tm2source
Data source for [Kartotherian's fork  of OSM Bright](https://github.com/kartotherian/osm-bright.tm2)

# Install
This style requires an osm2pgsql database with ocean data, custom indexes, and custom functions.

It's probably easiest to grab an PBF of OSM data from [Mapzen](https://mapzen.com/metro-extracts/) or [geofabrik](http://download.geofabrik.de/). Once you've installed PostgreSQL and PostGIS, create a database and import with osm2pgsql:

```sh
createdb gis
psql -d gis -c 'CREATE EXTENSION postgis; CREATE EXTENSION hstore;'
osm2pgsql -d gis -E 900913 --hstore ~/path/to/data.osm.pbf
```

You can find a more detailed guide to setting up a database and loading data with osm2pgsql at [switch2osm.org](http://switch2osm.org/loading-osm-data/).

Next we need some shapefiles

```sh
curl -O http://data.openstreetmapdata.com/water-polygons-split-3857.zip
unzip water-polygons-split-3857.zip && rm water-polygons-split-3857.zip
cd water-polygons-split-3857
shp2pgsql -I -s 3857 -g way water_polygons.shp water_polygons | psql -Xqd gis
psql -Xqd gis -c "select UpdateGeometrySRID('', 'water_polygons', 'way', 900913);"
```

Then some custom functions and indexes

```sh
cd .. # return to osm-bright.tm2source directory
npm install
psql -Xqd gis -f node_modules/postgis-vt-util/lib.sql
psql -Xqd gis -f sql/admin.sql
psql -Xqd gis -f sql/functions.sql
psql -Xqd gis -f sql/create-indexes.sql
psql -d gis -c 'select populate_admin();'
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
* `waterway` - [http://wiki.openstreetmap.org/wiki/Key:waterway](streams, rivers on low zoom, etc).
* `water` - water bodies (oceans, lakes, rivers wide enough on a given zoom level to be represented by areas as opposed to lines).
* `aeroway` - both areas and lines related to airports: [http://wiki.openstreetmap.org/wiki/Key:aeroway](tarmacs, taxiing lines, etc).
* `building` - buildings.
* `road` - roads and other similar transport ways: streets, bridges and tunnels.
* `admin` - [http://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative](administrative borders) between countries and regions.
* `country_label` - country labels.
* `place_label` - city/neighborhood/district labels.
* `poi_label` - places of interest. Currently, only transport stations are implemented.
* `road_label` - road labels, including highway number shields.
