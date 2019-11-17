

drop table if exists dc_routing.cabi_stations_updated;
CREATE TABLE dc_routing.cabi_stations_updated AS (
  SELECT
    bsst.*,
    vrtx.id as vertex,
    vrtx.distance as distance_to_nn
  FROM (select g.*
        FROM dc_routing.cabi_stations g,
            dc_routing.ruff_dc_outline h
        WHERE ST_INTERSECTS(g.geom, h.geom)) as bsst
  CROSS JOIN LATERAL
    (SELECT
      id,
      ST_DISTANCE(bsst.geom, vtx.the_geom) as distance
    FROM (SELECT *
            FROM dc_routing.dc_ways_vertices_pgr g
            WHERE g.cnt > 2) as vtx
  ORDER BY bsst.geom <-> vtx.the_geom
LIMIT 1) as vrtx
);

drop table dc_routing.cabi_stations;
