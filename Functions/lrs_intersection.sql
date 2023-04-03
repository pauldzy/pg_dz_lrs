CREATE OR REPLACE FUNCTION dz_lrs.lrs_intersection(
    IN  p_geometry1           GEOMETRY
   ,IN  p_geometry2           GEOMETRY
) RETURNS GEOMETRY
IMMUTABLE
AS
$BODY$ 
DECLARE
   sdo_broken       GEOMETRY;
   sdo_in           GEOMETRY;
   sdo_intersection GEOMETRY;
   sdo_initial      GEOMETRY;
   sdo_newinter     GEOMETRY;
   sdo_out          GEOMETRY;
   
BEGIN

   ----------------------------------------------------------------------------
   -- Step 10
   -- Check over incoming parameters
   ----------------------------------------------------------------------------
   IF ST_GeometryType(p_geometry1) NOT IN ('ST_LineString','ST_MultiLineString','ST_GeometryCollection')
   OR NOT dz_lrs.is_lrs(p_geometry1)
   THEN
      RAISE EXCEPTION 'geometry 1 must be LRS linestring or collection of LRS linestrings.';
      
   END IF;
   
   IF ST_GeometryType(p_geometry2) NOT IN ('ST_Polygon','ST_MultiPolygon')
   THEN
      RAISE EXCEPTION 'geometry 2 must be a polygon or multipolygon';
      
   END IF;
   
   IF ST_SRID(p_geometry1) != ST_SRID(p_geometry2)
   THEN
      RAISE EXCEPTION 'geometries must have the same SRID.';
   
   END IF;
   
   ----------------------------------------------------------------------------
   -- Step 20
   -- Break down any non-simple or closed LRS inputs
   ----------------------------------------------------------------------------
   FOR i IN 1 .. ST_NumGeometries(p_geometry1)
   LOOP
      sdo_in := ST_GeometryN(p_geometry1,i);
      
      IF ST_GeometryType(sdo_in) = 'ST_LineString'
      THEN
         sdo_in := dz_lrs.break_nonsimple_lrs(sdo_in);
         sdo_in := dz_lrs.break_closed_lrs(sdo_in);
         
         sdo_broken := dz_lrs.append_flat(sdo_broken,sdo_in);
         
      END IF;
      
   END LOOP;

   ----------------------------------------------------------------------------
   -- Step 30
   -- Intersect against all components of the LRS geometry
   ----------------------------------------------------------------------------
   FOR i IN 1 .. ST_NumGeometries(sdo_broken)
   LOOP
      sdo_in := ST_GeometryN(sdo_broken,i);
      
   ----------------------------------------------------------------------------
   -- Step 40
   -- Do the intersection
   ----------------------------------------------------------------------------
      sdo_intersection := ST_Intersection(
          sdo_in
         ,p_geometry2
      );
   
   ----------------------------------------------------------------------------
   -- Step 50
   -- See what we got
   ----------------------------------------------------------------------------
      IF ST_GeometryType(sdo_intersection) IS NULL
      THEN
         NULL; -- do nothing, no results
         
      ELSIF ST_GeometryType(sdo_intersection) = 'ST_MultiPoint'
      THEN
         NULL; -- do nothing, ignore multipoints
         
      ELSIF ST_GeometryType(sdo_intersection) IN (
          'ST_LineString'
         ,'ST_GeometryCollection'
         ,'ST_MultiLineString'
      )
      THEN
         sdo_newinter := NULL;
         
         FOR j IN 1 .. ST_NumGeometries(sdo_intersection)
         LOOP
            sdo_initial := ST_GeometryN(sdo_intersection,j);
            
            IF ST_GeometryType(sdo_initial) = 'ST_LineString'
            THEN
               sdo_initial := dz_lrs.overlay_measures(
                   p_geometry1 := sdo_initial
                  ,p_geometry2 := sdo_in
               );

               sdo_newinter := dz_lrs.safe_concatenate_geom_segments(
                   sdo_newinter
                  ,sdo_initial
               );
               
            END IF;
         
         END LOOP;
         
         IF sdo_newinter IS NOT NULL
         AND ST_GeometryType(sdo_newinter) NOT IN ('ST_LineString','ST_MultiLineString')
         THEN
            RAISE EXCEPTION 'unable to process geometry % (%)',j,ST_GeometryType(sdo_newinter);
            
         END IF;
         
         sdo_out := dz_lrs.append_flat(sdo_out,sdo_newinter);
         
      ELSE
         RAISE EXCEPTION 
             'intersection returned component gtype %'
            , ST_GeometryType(sdo_intersection);
      
      END IF;

   END LOOP;
   
   --------------------------------------------------------------------------
   -- Step 60
   -- Return what we got
   --------------------------------------------------------------------------
   RETURN sdo_out;
   
END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.lrs_intersection(
    GEOMETRY
   ,GEOMETRY
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.lrs_intersection(
    GEOMETRY
   ,GEOMETRY
) TO PUBLIC;

