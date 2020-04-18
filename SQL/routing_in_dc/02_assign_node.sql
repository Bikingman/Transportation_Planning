

DROP TABLE IF EXISTS      dc_routing.cabi_stations_updated;
CREATE TABLE              dc_routing.cabi_stations_updated AS (
  SELECT
                          bsst.*,
                          vrtx.id as vertex,
                          vrtx.distance as distance_to_nn
FROM
  (SELECT                 g.*
   FROM                   dc_routing.cabi_stations g, -- station points
                          dc_routing.ruff_dc_outline h -- outline of dc
   WHERE                  ST_INTERSECTS(g.geom, h.geom)) as bsst
CROSS JOIN LATERAL
  (SELECT
                          id,
                          ST_DISTANCE(bsst.geom, vtx.the_geom) as distance
   FROM (SELECT              *
         FROM              dc_routing.dc_ways_vertices_pgr g
         WHERE             g.cnt > 2) as vtx -- select vertex with at least 3 legs 
   ORDER BY                bsst.geom <-> vtx.the_geom -- closest
   LIMIT 1)                as vrtx
);

DROP TABLE                 dc_routing.cabi_stations; --cleanup
