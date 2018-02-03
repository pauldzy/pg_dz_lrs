CREATE OR REPLACE FUNCTION dz_lrs.safe_concatenate_geom_segments(
    IN  pGeometry1           GEOMETRY
   ,IN  pGeometry2           GEOMETRY
) RETURNS GEOMETRY
IMMUTABLE
AS
$BODY$ 
DECLARE
   sdo_array_in      GEOMETRY[];
   sdo_array_in2     GEOMETRY[];
   sdo_concatenate   GEOMETRY;
   sdo_output        GEOMETRY;
   num_remove1       NUMERIC;
   num_remove2       NUMERIC;
   int_counter       INTEGER;
   int_sanity        INTEGER := 0;
   
BEGIN

   ----------------------------------------------------------------------------
   -- Step 10
   -- Check over incoming parameters
   ----------------------------------------------------------------------------
   IF pGeometry1 IS NULL
   THEN
      RETURN NULL;
      
   END IF;
   
   IF pGeometry2 IS NULL
   THEN
      RETURN pGeometry1;
      
   END IF;

   IF ST_GeometryType(pGeometry1) NOT IN ('ST_LineString','ST_MultiLineString')
   OR NOT dz_lrs.is_lrs(pGeometry1)
   THEN
      RAISE EXCEPTION 'geometry 1 must be LRS linestring';
      
   END IF;
   
   IF ST_GeometryType(pGeometry2) NOT IN ('ST_LineString','ST_MultiLineString')
   OR NOT dz_lrs.is_lrs(pGeometry2)
   THEN
      RAISE EXCEPTION 'geometry 2 must be LRS linestring';
      
   END IF;
   
   ----------------------------------------------------------------------------
   -- Step 20
   -- Do the easiest solution of two single linestrings
   ----------------------------------------------------------------------------
   IF  ST_GeometryType(pGeometry1) = 'ST_LineString'
   AND ST_GeometryType(pGeometry2) = 'ST_LineString'
   THEN
      IF ST_M(ST_EndPoint(pGeometry1)) = ST_M(ST_StartPoint(pGeometry2))
      THEN
         RETURN ST_MakeLine(
             pGeometry1
            ,pGeometry2
         );
         
      ELSIF ST_M(ST_EndPoint(pGeometry2)) = ST_M(ST_StartPoint(pGeometry1))
      THEN
         RETURN ST_MakeLine(
             pGeometry2
            ,pGeometry1
         );
         
      ELSE
         RETURN ST_Collect(
             pGeometry2
            ,pGeometry1
         );
      
      END IF;
      
   END IF;
   
   ----------------------------------------------------------------------------
   -- Step 30
   -- Create an array of all the linestrings in both geometries
   ----------------------------------------------------------------------------
   SELECT
   array_agg(a.geom)
   INTO
   sdo_array_in
   FROM (
      SELECT (ST_Dump(
         ST_Collect(pGeometry1,pGeometry2)
      )).*
   ) a;
   
   ----------------------------------------------------------------------------
   -- Step 40
   -- Set an anchor point for processing
   ----------------------------------------------------------------------------
   <<start_over>>
   LOOP
      num_remove1   := NULL;
      num_remove2   := NULL;
      sdo_array_in2 := NULL;
      
   ----------------------------------------------------------------------------
   -- Step 50
   -- Loop over all the linestrings and search for match
   ----------------------------------------------------------------------------
      <<outer_loop>>
      FOR i IN 1 .. array_length(sdo_array_in, 1)
      LOOP
         FOR j IN 1 .. array_length(sdo_array_in, 1)
         LOOP
            IF i <> j
            AND ST_M(ST_EndPoint(sdo_array_in[i])) = ST_M(ST_StartPoint(sdo_array_in[j]))
            THEN
               sdo_concatenate := ST_MakeLine(
                   sdo_array_in[i]
                  ,sdo_array_in[j]
               );
               
               IF ST_GeometryType(sdo_concatenate) = 'ST_LineString'
               THEN
                  num_remove1 := i;
                  num_remove2 := j;
                  EXIT outer_loop;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
      END LOOP outer_loop;

   --------------------------------------------------------------------------
   -- Step 60
   -- Bail if there are no matches in the mess
   --------------------------------------------------------------------------
      IF num_remove1 IS NULL
      THEN
         sdo_output := ST_Collect(sdo_array_in);
         
         IF ST_NumGeometries(sdo_output) = 1
         THEN
            RETURN ST_GeometryN(sdo_output,1);
         
         ELSE
            RETURN sdo_output;
         
         END IF;
         
      END IF;
  
   --------------------------------------------------------------------------
   -- Step 70
   -- Add match to start of array and remove parts from array
   --------------------------------------------------------------------------
      int_counter := 1;
      sdo_array_in2[int_counter] := sdo_concatenate;
      int_counter := int_counter + 1;
      
      FOR i IN 1 .. array_length(sdo_array_in,1)
      LOOP
         IF  i <> num_remove1
         AND i <> num_remove2
         THEN
            sdo_array_in2[int_counter] := sdo_array_in[i];
            int_counter := int_counter + 1;
            
         END IF;
         
      END LOOP;
      
      sdo_array_in := sdo_array_in2;
   
   --------------------------------------------------------------------------
   -- Step 80
   -- Check that loop is not stuck
   --------------------------------------------------------------------------
      IF int_sanity > array_length(sdo_array_in,1) * array_length(sdo_array_in,1)
      THEN
         sdo_output := ST_Collect(sdo_array_in);
         
         IF ST_NumGeometries(sdo_output) = 1
         THEN
            RETURN ST_GeometryN(sdo_output,1);
         
         ELSE
            RETURN sdo_output;
         
         END IF;
         
      END IF;
   
      int_sanity := int_sanity + 1;
      
   END LOOP start_over; 
   
END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.safe_concatenate_geom_segments(
    geometry
   ,geometry
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.safe_concatenate_geom_segments(
    geometry
   ,geometry
) TO PUBLIC;

