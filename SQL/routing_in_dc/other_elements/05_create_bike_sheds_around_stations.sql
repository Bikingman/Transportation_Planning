


select dc_routing.make_isochronesx('cabi_stations_updated', 2640);
select dc_routing.make_isochronesx('cabi_stations_updated', 5280);


--write buffer

ALTER TABLE dc_routing.cabi_stations_updated_iso_2640
ADD COLUMN geom2 geometry(MultiPolygon, 2283);
UPDATE dc_routing.cabi_stations_updated_iso_2640
SET geom2 = ST_BUFFER(geom, 0.0003440336041);
-- TODO finish this


-- 
-- ALTER TABLE cabi_stations_updated_iso_5280
-- ADD COLUMN geom2 geometry(Polygon, 2283);
-- UPDATE all_schools_iso_2640
-- SET geom2 = ST_BUFFER(geom, 0.0003440336041);
--
--
-- -- drop and replace old buffer
--
-- ALTER TABLE cabi_stations_updated_iso_2640
-- DROP COLUMN geom;
-- ALTER TABLE cabi_stations_updated_iso_5280
-- DROP COLUMN geom;
--
-- ALTER TABLE cabi_stations_updated_iso_2640
-- RENAME COLUMN geom2 TO geom;
-- ALTER TABLE cabi_stations_updated_iso_5280
-- RENAME COLUMN geom2 TO geom;
--
--
-- -- create unioned buffers
--
-- DROP TABLE IF EXISTS cabi_stations_updated_iso_2640;
-- CREATE TABLE cabi_stations_updated_iso_2640 as (
-- SELECT
--   ST_UNION(geom) as geom
-- FROM cabi_stations_sheds_iso_2640
-- );
--
-- DROP TABLE IF EXISTS cabi_stations_updated_iso_5280;
-- CREATE TABLE cabi_stations_updated_iso_5280 as (
-- SELECT
--   ST_UNION(geom) as geom
-- FROM cabi_stations_sheds_iso_5280
-- );
--
-- -- drop old isos
--
-- DROP TABLE cabi_stations_updated_iso_2640;
-- DROP TABLE cabi_stations_updated_iso_5280;
