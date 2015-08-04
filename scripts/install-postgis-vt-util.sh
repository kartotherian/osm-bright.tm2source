#!/bin/sh

psql -f `dirname "$0"`/../node_modules/postgis-vt-util/lib.sql gis
