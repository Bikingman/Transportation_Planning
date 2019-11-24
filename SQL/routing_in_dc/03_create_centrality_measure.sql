


DROP TABLE IF EXISTS dc_routing.trips_centrality;
CREATE TABLE dc_routing.trips_centrality as (
SELECT
  b.gid,
  b.the_geom as geom,
  count(the_geom) as count
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
GROUP BY b.gid, b.the_geom, gg.member_type);



DROP TABLE IF EXISTS dc_routing.trips_centrality_by_member_type;
CREATE TABLE dc_routing.trips_centrality_by_member_type as (
  SELECT b.gid, b.the_geom as geom, gg.member_type, count(the_geom) as count
  FROM dc_routing.cabi_trips_short gg,
  pgr_dijkstra('
    SELECT
    g.gid as id,
    g.source,
    g.target,
    g.length as cost FROM dc_routing.dc_ways g',
    gg.source_point, gg.target_point,
    directed := FALSE) j
    JOIN
    dc_routing.dc_ways
    AS b
    ON
    j.edge = b.gid
    GROUP BY b.gid, b.the_geom, gg.member_type);
