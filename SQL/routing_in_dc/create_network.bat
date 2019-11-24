

bzcat /Users/Bikingman/Documents/osm_data/district-of-columbia-latest.osm.bz2 > /Users/Bikingman/Documents/dc_osm_data.osm
osm2pgrouting -f /Users/Bikingman/Documents/dc_osm_data.osm -h localhost -U postgres -d routing --schema dc_routing --prefix dc_ -p 5432 -W user --conf=/Users/Bikingman/Documents/GitHub/Transportation_Planning/SQL/routing_in_dc/default_config.xml

osm2pgrouting -f /Users/Bikingman/Documents/dc_osm_data.osm -h localhost -U postgres -d routing --schema dc_routing --prefix dc_b_ -p 5432 -W user --conf=/Users/Bikingman/Documents/GitHub/Transportation_Planning/SQL/routing_in_dc/bike_config.xml

osm2pgrouting -f /Users/Bikingman/Documents/dc_osm_data.osm -h localhost -U postgres -d routing --schema dc_routing --prefix dc_v_ -p 5432 -W user --conf=/Users/Bikingman/Documents/GitHub/Transportation_Planning/SQL/routing_in_dc/veh_config.xml
