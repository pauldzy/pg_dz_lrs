CREATE OR REPLACE FUNCTION dz_lrs.lrs_intersection(
    IN  pGeometry1           geometry
   ,IN  pGeometry2           geometry
) RETURNS geometry 
AS
$BODY$ 
DECLARE
   sdo_intersection geometry;
   sdo_initial      geometry;
   sdo_newinter     geometry;
   
BEGIN

   ----------------------------------------------------------------------------
   -- Step 10
   -- Check over incoming parameters
   ----------------------------------------------------------------------------
   IF ST_GeometryType(pGeometry1) <> 'ST_LineString'
   OR ST_M(ST_StartPoint(pGeometry1)) IS NULL
   THEN
      RAISE EXCEPTION 'geometry 1 must be single LRS linestring';
      
   END IF;
   
   IF ST_GeometryType(pGeometry2) NOT IN ('ST_Polygon','ST_MultiPolygon')
   THEN
      RAISE EXCEPTION 'geometry 2 must be a polygon or multipolygon';
      
   END IF;
   
   ----------------------------------------------------------------------------
   -- Step 20
   -- Do the intersection
   ----------------------------------------------------------------------------
   sdo_intersection := ST_Intersection(
       pGeometry1
      ,pGeometry2
   );
   
   ----------------------------------------------------------------------------
   -- Step 30
   -- Now see what we got
   ----------------------------------------------------------------------------
   IF ST_GeometryType(sdo_intersection) IS NULL
   THEN
      RETURN NULL;
      
   ELSIF ST_GeometryType(sdo_intersection) = 'ST_MultiPoint'
   THEN
      RETURN NULL;
      
   ELSIF ST_GeometryType(sdo_intersection) IN (
       'ST_LineString'
      ,'ST_GeometryCollection'
      ,'ST_MultiLineString'
   )
   THEN
      NULL;  -- Do nothing
      
   ELSE
      RAISE EXCEPTION 
          'intersection returned component gtype %'
         , ST_GeometryType(sdo_intersection);
   
   END IF;
   
   ----------------------------------------------------------------------------
   -- Step 40
   -- Pick out the linestrings
   ----------------------------------------------------------------------------
   FOR i IN 1 .. ST_NumGeometries(sdo_intersection)
   LOOP
      sdo_initial := ST_GeometryN(sdo_intersection,i);
      
      IF ST_GeometryType(sdo_initial) = 'ST_LineString'
      THEN
         sdo_initial := dz_lrs.overlay_measures(
             pGeometry1 := sdo_initial
            ,pGeometry2 := pGeometry1
         );

         IF sdo_newinter IS NULL
         THEN
            sdo_newinter := sdo_initial;
            
         ELSE
            sdo_newinter := dz_lrs.safe_concatenate_geom_segments(
                sdo_newinter
               ,sdo_initial
            );
            
         END IF;
         
      END IF;
   
   END LOOP;
   
   --------------------------------------------------------------------------
   -- Step 50
   -- Final check and then return the results
   --------------------------------------------------------------------------
   IF ST_GeometryType(sdo_newinter) NOT IN ('ST_LineString','ST_MultiLineString')
   THEN
      RAISE EXCEPTION 'unable to process geometry';
      
   END IF;

   --------------------------------------------------------------------------
   -- Step 60
   -- Return what we got
   --------------------------------------------------------------------------
   RETURN sdo_newinter;
   
END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.lrs_intersection(
    geometry
   ,geometry
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.lrs_intersection(
    geometry
   ,geometry
) TO PUBLIC;

