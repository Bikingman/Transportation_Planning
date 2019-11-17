--https://stackoverflow.com/questions/10621897/replace-empty-strings-with-null-values
SELECT f_empty2null('routing."metro-bike-share-trip-data"');


DROP TABLE IF EXISTS la_bikeshare_trips_2019;
CREATE TABLE la_bikeshare_trips_2019 AS (
SELECT
id::INT as p_key,
"Trip ID"::INT as trip_id,
"Duration"::INT as duration,
"Start Time" as start_time,
"End Time" as end_time,
"Starting Station ID"::INT as start_station_id,
"Starting Station Latitude"::FLOAT as start_station_lat,
"Starting Station Longitude"::FLOAT as start_station_lon,
"Ending Station ID"::INT as end_station_id,
"Ending Station Latitude"::FLOAT end_station_lat,
"Ending Station Longitude"::FLOAT end_station_lon,
"Bike ID"::INT as bike_id,
"Plan Duration"::TEXT as plan_duration,
"Trip Route Category"::TEXT as trip_route_cat,
"Passholder Type"::VARCHAR(30) passholder_type,
"Starting Lat-Long" as start_lat_lon,
"Ending Lat-Long" as end_lat_lon,
"Neighborhood Councils (Certified)"::TEXT as neighb_conc_cert,
"Council Districts"::TEXT council_dist,
"Zip Codes"::INT as zip_code,
"LA Specific Plans"::TEXT as la_plan,
"Precinct Boundaries" as precinct_bound,
"Census Tracts" as census_tract,
NULL::geometry(point, 4326) as geom_start,
NULL::geometry(point, 4326) as geom_end
	FROM routing."metro-bike-share-trip-data");

ALTER TABLE la_bikeshare_trips_2019
ADD PRIMARY KEY (p_key);

UPDATE la_bikeshare_trips_2019
set geom_start = ST_SetSRID(ST_MAKEPOINT(start_station_lat, start_station_lon), 4326),
geom_end = ST_SETSRID(ST_MAKEPOINT(end_station_lat, end_station_lon), 4326);

CREATE INDEX la_bikeshare_index_start
on la_bikeshare_trips_2019
USING GIST (geom_start);

CREATE INDEX la_bikeshare_index_end
on la_bikeshare_trips_2019
USING GIST (geom_end);



SELECT seq, edge, rpad(b.the_geom::text,60,' ') AS "the_geom (truncated)"
        FROM pgr_dijkstra('
                SELECT gid as id, source, target,
                        length as cost FROM ways',
                100, 600, false
        ) a INNER JOIN ways b ON (a.edge = b.gid) ORDER BY seq;
