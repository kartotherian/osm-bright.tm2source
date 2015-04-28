# osm2pgsql-osm-bright.tm2source
Mapbox studio source files for osm2pgsql imported database


Tables:
planet_osm_point, planet_osm_line, planet_osm_polygon, planet_osm_roads

Common fields: access, "addr:housename", "addr:housenumber", "addr:interpolation", admin_level, aerialway, aeroway, amenity, area, barrier, bicycle, boundary, brand, bridge, building, construction, covered, culvert, cutting, denomination, disused, embankment, foot, "generator:source", harbour, highway, historic, horse, intermittent, junction, landuse, layer, leisure, lock, man_made, military, motorcar, name, natural, office, oneway, operator, place, population, power, power_source, public_transport, railway, ref, religion, route, service, shop, sport, surface, toll, tourism, "tower:type", tunnel, water, waterway, wetland, width, wood

Fields in planet_osm_point only:
  capital, poi, ele

Fields in planet_osm_line, planet_osm_polygon, planet_osm_roads, but not in ..._point:
  tracktype
