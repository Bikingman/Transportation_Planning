
    CREATE OR REPLACE FUNCTION dc_routing.make_isochronesx(v_input text, v_cost integer)
      RETURNS integer AS
    $BODY$
    DECLARE
    	cur_src refcursor;    --set some variables
    	v_nn integer;
    	v_geom geometry;
    	v_tbl varchar(200);
    	v_sql varchar(1000);
    BEGIN
    	RAISE NOTICE 'Dropping isochrone table...';
    	-- Drop the table being created if it exists
    	v_sql:='DROP TABLE IF EXISTS dc_routing.'||v_input||'_iso_'||v_cost;
    	EXECUTE v_sql;
    	RAISE NOTICE 'Creating isochrone table...';
    	-- Create the table to hold the data if it doesn't exist
    	v_sql:='CREATE TABLE IF NOT EXISTS dc_routing.'||v_input||'_iso_'||v_cost||'
    		( id serial NOT NULL,
    		  node_id integer,
    		  geom geometry(Polygon,2283),
    		  CONSTRAINT '||v_input||'_iso_'||v_cost||'_pkey PRIMARY KEY (id)
    		);
    		CREATE INDEX '||v_input||'_iso_'||v_cost||'_geom
    		  ON dc_routing.'||v_input||'_iso_'||v_cost||'
    		  USING gist
    		  (geom);';
    	EXECUTE v_sql;
    	RAISE NOTICE 'Creating temporary node table...';
    	-- Drop then recreate temporary node table from dc_routing.dc_wayss used in generating isochrones
    	DROP TABLE IF EXISTS node;
    	CREATE TEMPORARY TABLE node AS
    	    SELECT id::int,
    		ST_X(geom) AS x,
    		ST_Y(geom) AS y,
    		geom
    		FROM (
    		    SELECT source AS id,
    			ST_Startpoint(the_geom) AS geom
    			FROM dc_routing.dc_ways
    		    UNION
    		    SELECT target AS id,
    			ST_Startpoint(the_geom) AS geom
    			FROM dc_routing.dc_ways
    		) AS node;
    	RAISE NOTICE 'Calculating isochrones...';
    	-- Loop through the input features, creating an isochrone for each one, and insert into the output table
    	OPEN cur_src FOR EXECUTE format('SELECT vertex::int4 FROM dc_routing.'||v_input );
    	LOOP
    	FETCH cur_src INTO v_nn;
    	EXIT WHEN NOT FOUND;
    	SELECT ST_SetSRID(ST_MakePolygon(ST_AddPoint(foo.openline, ST_StartPoint(foo.openline))),2283) AS geom
    	FROM (
    	  SELECT ST_Makeline(points ORDER BY id) AS openline
    	  FROM (
    	    SELECT row_number() over() AS id, ST_MakePoint(x, y) AS points
    	    FROM pgr_alphashape('
    		SELECT *
    		FROM node
    		    JOIN
    		    (SELECT * FROM pgr_drivingDistance(''
    			SELECT gid::integer AS id,
    			source::int4 AS source,
    			target::int4 AS target,
    			cost_f_ft::float8 AS cost,
    			cost_r_ft::float8 AS reverse_cost
    			FROM dc_routing.dc_ways'',
    			'||v_nn||',
    			'||v_cost||',
    			true,
    			true)) AS dd ON node.id = dd.id1'::text)
    	  ) AS a
    	) AS foo INTO v_geom;
    	-- Set the table name
    	v_tbl:='dc_routing.'||v_input||'_iso_'||v_cost;
    	-- Insert the isochrone geometries into the table
    	EXECUTE format('INSERT INTO %s(node_id,geom) VALUES ($1,$2)',v_tbl)
    		USING v_nn, v_geom;
    	END LOOP;
    	RETURN 1;
    	CLOSE cur_src;
    END;
    $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 1;
