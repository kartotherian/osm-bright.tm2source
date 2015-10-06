# osm-bright.tm2source
Data source for [Kartotherian's fork  of OSM Bright](https://github.com/kartotherian/osm-bright.tm2)

# Requirements
See [Kartotherian documentation](https://github.com/kartotherian/kartotherian/blob/master/README.md) for details. **Be sure to import the OSM data with `--hstore` key**.

# Layers
The order of layers in this style matters because that's the order that they will be drawn on map. Note that the list of layers goes from bottom to top, opposite to the order in files.
* `landuse` - various uses for land: wood, park, industrial zone, etc. Mostly corresponds to OSM's [`landuse` key](http://wiki.openstreetmap.org/wiki/Key:landuse).
* `waterway` - water lines (streams, rivers on low zoom, etc).
* `water` - water bodies (oceans, lakes, rivers wide enough on a given zoom level to be represented by areas as opposed to lines).
* `aeroway` - both areas and lines related to airports: tarmacs, taxiing lines, etc.
* `building` - buildings.
* `road` - roads and other similar transport ways: streets, bridges and tunnels.
* `admin` - administrative borders between countries and regions.
* `country_label` - country labels.
* `place_label` - city/neighborhood/district labels.
* `road_label` - road labels, including highway number shields.
  
# Editing
To edit this data source, you need to have some OSM data on your local machine. Follow [data set up instructions](https://github.com/kartotherian/kartotherian/blob/master/README.md#in-depth-step-by-step) from [Kartotherian](https://github.com/kartotherian/kartotherian).
* Install the latest [Mapbox Studio Classic](https://www.mapbox.com/mapbox-studio-classic/)
* Clone [osm-bright.tm2source](https://github.com/kartotherian/osm-bright.tm2source) repository (this one)
Open Mapbox Studio and open the data source. You should see your data as "x-ray" outlines. Don't edit just data.yml or data.xml - they must be in sync; editing this project in MBS only ensures that.

To see the data in style
* Clone [osm-bright.tm2](https://github.com/kartotherian/osm-bright.tm2) repository
* Edit style's project.yml - change the `source:` to `"tmsource:///home/user/.../osm-bright.tm2source"` directory.
Open it in the Mapbox Studio.
