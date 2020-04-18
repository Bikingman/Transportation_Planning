DROP TABLE IF EXISTS    dc_routing.cabi_trips_short;
CREATE TABLE            dc_routing.cabi_trips_short AS (
  SELECT
                        id::INT as old_id,
                        "Duration"::FLOAT as duration,
                        "Start date" as start_date,
                        "End date" as end_date,
                        "Start station number"::INT as start_station_id,
                        "Start station" start_station_name,
                        "End station number"::INT as end_station_id,
                        "End station" as end_station_name,
                        "Bike number" as bike_no,
                        "Member type" as member_type,
                        NULL::FLOAT as start_lat,
                        NULL::FLOAT as start_lon,
                        NULL::FLOAT as end_lat,
                        NULL::FLOAT as end_lon,
                        NULL::geometry(point) as start_geom,
                        NULL::geometry(point) as end_geom,
                        NULL::INT as source_point,
                        NULL::INT as target_point
  FROM                  dc_routing."201908-capitalbikeshare-tripdata"
  LIMIT                 5000
);

-- set
UPDATE                  dc_routing.cabi_trips_short gg
SET                     start_lat = g.latitude,
                        start_lon = g.longitude,
                        source_point = g.vertex
FROM                    dc_routing.cabi_stations_updated g
WHERE                   gg.start_station_id = cast(g.terminal_n as integer);

UPDATE                  dc_routing.cabi_trips_short gg
SET                     end_lat = g.latitude,
                        end_lon = g.longitude,
                        target_point = g.vertex
FROM                    dc_routing.cabi_stations_updated g
WHERE                   gg.end_station_id = cast(g.terminal_n as integer);

-- add primary key
ALTER TABLE             dc_routing.cabi_trips_short
ADD COLUMN              p_key BIGSERIAL;

ALTER TABLE             dc_routing.cabi_trips_short
ADD PRIMARY KEY         (p_key);

UPDATE                  dc_routing.cabi_trips_short
set start_geom =        ST_SetSRID(ST_MAKEPOINT(start_lon, start_lat), 4326),
end_geom =              ST_SETSRID(ST_MAKEPOINT(end_lon, end_lat), 4326);


ALTER TABLE             dc_routing.cabi_trips_short
ALTER COLUMN            start_geom TYPE geometry(Point,4326)
USING                   ST_SetSRID(start_geom,4326);

ALTER TABLE             dc_routing.cabi_trips_short
ALTER COLUMN            end_geom TYPE geometry(Point,4326)
USING                   ST_SetSRID(end_geom,4326);


CREATE INDEX            dc_bikeshare_index_start
on                      dc_routing.cabi_trips_short
USING GIST              (start_geom);
ANALYZE                 dc_routing.cabi_trips_short;

CREATE INDEX            dc_bikeshare_index_end
on                      dc_routing.cabi_trips_short
USING GIST              (end_geom);
ANALYZE                 dc_routing.cabi_trips_short;
