

DROP TABLE IF EXISTS routing.la_bikeshare_trips_2019;
CREATE TABLE routing.la_bikeshare_trips_2019 AS (
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

ALTER TABLE routing.la_bikeshare_trips_2019
ADD PRIMARY KEY (p_key);

UPDATE routing.la_bikeshare_trips_2019
set geom_start = ST_SetSRID(ST_MAKEPOINT(start_station_lon, start_station_lat), 4326),
geom_end = ST_SETSRID(ST_MAKEPOINT(end_station_lon, end_station_lat), 4326);



ALTER TABLE routing.la_bikeshare_trips_2019
 ALTER COLUMN geom_start TYPE geometry(Point,4326)
  USING ST_SetSRID(geom_start,4326);

	ALTER TABLE routing.la_bikeshare_trips_2019
 ALTER COLUMN geom_end TYPE geometry(Point,4326)
  USING ST_SetSRID(geom_end,4326);


CREATE INDEX la_bikeshare_index_start
on routing.la_bikeshare_trips_2019
USING GIST (geom_start);

CREATE INDEX la_bikeshare_index_end
on routing.la_bikeshare_trips_2019
USING GIST (geom_end);

--TODO: route all trips, study the xml file and what that does to routing
--also may want to bring in bike share station points and join counts... or create clustered points
-- 
