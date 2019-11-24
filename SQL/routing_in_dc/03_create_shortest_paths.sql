

DROP TABLE IF EXISTS dc_routing.trips_start;
CREATE TABLE dc_routing.trips_start as (
SELECT
  gg.p_key,
    b.gid,
  ST_MAKELINE(b.the_geom) as geom
FROM
dc_routing.cabi_trips_short gg,
  pgr_dijkstra(
      'SELECT
         g.gid as id,
	 	 g.source,
	  	g.target,
	  	g.length as cost
          FROM dc_routing.dc_ways g', gg.source_point, gg.target_point, directed := FALSE) j
          JOIN    dc_routing.dc_ways AS b
            ON    j.edge = b.gid
GROUP BY gg.p_key, b.gid);


DROP TABLE IF EXISTS dc_routing.trips_merged;
CREATE TABLE dc_routing.trips_merged AS (
  SELECT
  p_key,
  ST_UNION(geom) as geom
  FROM dc_routing.trips_start
  GROUP BY p_key
);


DROP TABLE IF EXISTS dc_routing.trips;
CREATE TABLE dc_routing.trips as (
SELECT
  lines.p_key,
  points.duration,
  points.start_date,
  points.end_date,
  points.start_station_id,
  points.start_station_name,
  points.end_station_id,
  points.end_station_name,
  points.bike_no,
  points.member_type,
  points.start_lat,
  points.start_lon,
  points.end_lat,
  points.end_lon,
  points.source_point,
  points.target_point,
  lines.geom
FROM dc_routing.trips_merged lines
LEFT OUTER JOIN dc_routing.cabi_trips_short points
ON points.p_key = lines.p_key);


DROP TABLE IF EXISTS dc_routing.trips_merged;
DROP TABLE IF EXISTS dc_routing.trips_start;

--
--
-- -----------
-- -- bike priority
-- -----------
--
-- DROP TABLE IF EXISTS dc_routing.trips_start_bike;
-- CREATE TABLE dc_routing.trips_start_bike as (
-- SELECT
--   gg.p_key,
--     b.gid,
--   ST_MAKELINE(b.the_geom) as geom
-- FROM
-- dc_routing.cabi_trips_short gg,
--   pgr_dijkstra(
--       'SELECT
--          g.gid as id,
-- 	 	 g.source,
-- 	  	g.target,
-- 	  	g.length as cost
--           FROM dc_routing.dc_b_ways g', gg.source_point, gg.target_point, directed := FALSE) j
--           JOIN    dc_routing.dc_ways AS b
--             ON    j.edge = b.gid
-- GROUP BY gg.p_key, b.gid);
--
--
-- DROP TABLE IF EXISTS dc_routing.trips_merged_bike;
-- CREATE TABLE dc_routing.trips_merged_bike AS (
--   SELECT
--   p_key,
--   ST_UNION(geom) as geom
--   FROM dc_routing.trips_start_bike
--   GROUP BY p_key
-- );
--
--
-- DROP TABLE IF EXISTS dc_routing.trips_bike;
-- CREATE TABLE dc_routing.trips_bike as (
-- SELECT
--   lines.p_key,
--   points.duration,
--   points.start_date,
--   points.end_date,
--   points.start_station_id,
--   points.start_station_name,
--   points.end_station_id,
--   points.end_station_name,
--   points.bike_no,
--   points.member_type,
--   points.start_lat,
--   points.start_lon,
--   points.end_lat,
--   points.end_lon,
--   points.source_point,
--   points.target_point,
--   lines.geom
-- FROM dc_routing.trips_merged lines
-- LEFT OUTER JOIN dc_routing.cabi_trips_short points
-- ON points.p_key = lines.p_key);
--
--
-- DROP TABLE IF EXISTS dc_routing.trips_merged_bike;
-- DROP TABLE IF EXISTS dc_routing.trips_start_bike;
--
-- --
-- -- -----
-- -- --vehicle
-- -- -----
-- --
-- --
-- -- DROP TABLE IF EXISTS dc_routing.trips_start_vehicle;
-- -- CREATE TABLE dc_routing.trips_start_bike as (
-- -- SELECT
-- --   gg.p_key,
-- --     b.gid,
-- --   ST_MAKELINE(b.the_geom) as geom
-- -- FROM
-- -- dc_routing.cabi_trips_short gg,
-- --   pgr_dijkstra(
-- --       'SELECT
-- --          g.gid as id,
-- -- 	 	 g.source,
-- -- 	  	g.target,
-- -- 	  	g.length as cost
-- --           FROM dc_routing.dc_b_ways g', gg.source_point, gg.target_point, directed := FALSE) j
-- --           JOIN    dc_routing.dc_ways AS b
-- --             ON    j.edge = b.gid
-- -- GROUP BY gg.p_key, b.gid);
-- --
-- --
-- -- DROP TABLE IF EXISTS dc_routing.trips_merged_bike;
-- -- CREATE TABLE dc_routing.trips_merged_bike AS (
-- --   SELECT
-- --   p_key,
-- --   ST_UNION(geom) as geom
-- --   FROM dc_routing.trips_start_bike
-- --   GROUP BY p_key
-- -- );
-- --
-- --
-- -- DROP TABLE IF EXISTS dc_routing.trips_bike;
-- -- CREATE TABLE dc_routing.trips_bike as (
-- -- SELECT
-- --   lines.p_key,
-- --   points.duration,
-- --   points.start_date,
-- --   points.end_date,
-- --   points.start_station_id,
-- --   points.start_station_name,
-- --   points.end_station_id,
-- --   points.end_station_name,
-- --   points.bike_no,
-- --   points.member_type,
-- --   points.start_lat,
-- --   points.start_lon,
-- --   points.end_lat,
-- --   points.end_lon,
-- --   points.source_point,
-- --   points.target_point,
-- --   lines.geom
-- -- FROM dc_routing.trips_merged lines
-- -- LEFT OUTER JOIN dc_routing.cabi_trips_short points
-- -- ON points.p_key = lines.p_key);
-- --
-- --
-- -- DROP TABLE IF EXISTS dc_routing.trips_merged_bike;
-- -- DROP TABLE IF EXISTS dc_routing.trips_start_bike;
