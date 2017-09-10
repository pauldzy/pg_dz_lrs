CREATE OR REPLACE FUNCTION dz_lrs.overlay_measures(
    IN  pGeometry1           geometry
   ,IN  pGeometry2           geometry
) RETURNS geometry 
AS
$BODY$ 
DECLARE
   sdo_input_start   geometry;
   sdo_input_end     geometry;
   num_start_meas    NUMERIC;
   num_end_meas      NUMERIC;
   sdo_lrs_output    geometry;
   
BEGIN

   ----------------------------------------------------------------------------
   -- Step 10
   -- Check over incoming parameters
   ----------------------------------------------------------------------------
   IF ST_GeometryType(pGeometry1)  <> 'ST_LineString'
   THEN
      RAISE EXCEPTION 'geometry 1 must a single linestring';
      
   END IF;
   
   IF ST_GeometryType(pGeometry2) <> 'ST_LineString'
   OR ST_M(ST_StartPoint(pGeometry2)) IS NULL
   THEN
      RAISE EXCEPTION 'geometry 2 must be single LRS linestring';
      
   END IF;
   
   --------------------------------------------------------------------------
   -- Step 20
   -- Collect the start and end points of the input geometry
   --------------------------------------------------------------------------
   sdo_input_start := ST_StartPoint(pGeometry1);
   sdo_input_end   := ST_EndPoint(pGeometry1);
   
   --------------------------------------------------------------------------
   -- Step 30
   -- Collect the start and end measure of the input geometry on the lrs
   --------------------------------------------------------------------------
   num_start_meas := ST_InterpolatePoint(
       pGeometry2
      ,sdo_input_start
   );
      
   num_end_meas := ST_InterpolatePoint(
       pGeometry2
      ,sdo_input_end
   );
   
   --------------------------------------------------------------------------
   -- Step 50
   -- Build the new LRS string from the measures
   --------------------------------------------------------------------------
   sdo_lrs_output := ST_AddMeasure(
       pGeometry1
      ,num_start_meas
      ,num_end_meas
   );
   
   --------------------------------------------------------------------------
   -- Step 50
   -- Check to see if the geometry is backwards
   --------------------------------------------------------------------------
   IF num_start_meas < num_end_meas
   THEN
      sdo_lrs_output := dz_lrs.reverse_linestring(
          pGeometry := sdo_lrs_output
      );
      
   END IF;

   --------------------------------------------------------------------------
   -- Step 60
   -- Return the results
   --------------------------------------------------------------------------
   RETURN sdo_lrs_output;
   
END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.overlay_measures(
    geometry
   ,geometry
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.overlay_measures(
    geometry
   ,geometry
) TO PUBLIC;

