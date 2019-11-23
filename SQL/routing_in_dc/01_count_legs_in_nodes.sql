
UPDATE dc_routing.dc_ways_vertices_pgr p
SET cnt = (select count(*) from dc_routing.dc_ways w
WHERE ST_DWITHIN(p.the_geom, w.the_geom, .000000000000001)); -- minimize those margins! 
