

bzcat ./osm_data/district-of-columbia-latest.osm.bz2 > ./dc_osm_data.osm

osm2pgrouting -f ./dc_osm_data.osm -h localhost -U postgres -d routing --schema dc_routing --prefix dc_b_ -p 5432 -W user --conf=./GitHub/Transportation_Planning/SQL/routing_in_dc/bike_config.xml
