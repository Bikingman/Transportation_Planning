
ALTER TABLE dc_routing.dc_ways_vertices_pgr
ALTER COLUMN the_geom TYPE geometry(Point,2283)
USING ST_SetSRID(the_geom,2283);

ALTER TABLE dc_routing.dc_ways
 ALTER COLUMN the_geom TYPE geometry(LineString,2283)
  USING ST_Transform(the_geom,2283);

ALTER TABLE dc_routing.dc_ways_vertices_pgr
 ALTER COLUMN geom TYPE geometry(MultiPolygon,2283)
  USING ST_Transform(geom,2283);

ALTER TABLE dc_routing.cabi_stations_updated
 ALTER COLUMN geom TYPE geometry(MultiPolygon,2283)
  USING ST_Transform(geom,2283);

ALTER TABLE dc_routing.dc_ways
DROP COLUMN cost_f_ft,
DROP COLUMN cost_r_ft;

ALTER TABLE dc_routing.dc_ways
ADD COLUMN cost_f_ft FLOAT,
ADD COLUMN cost_r_ft FLOAT;

UPDATE dc_routing.dc_ways
SET cost_f_ft = ST_length(the_geom),
cost_r_ft = ST_length(the_geom);
