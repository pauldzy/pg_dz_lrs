CREATE OR REPLACE FUNCTION dz_lrs.overlay_measures(
    IN  p_geometry1           GEOMETRY
   ,IN  p_geometry2           GEOMETRY
) RETURNS GEOMETRY
IMMUTABLE
AS
$BODY$ 
DECLARE
   sdo_input_start   GEOMETRY;
   sdo_input_end     GEOMETRY;
   num_start_meas    NUMERIC;
   num_end_meas      NUMERIC;
   sdo_lrs_output    GEOMETRY;
   
BEGIN

   ----------------------------------------------------------------------------
   -- Step 10
   -- Check over incoming parameters
   ----------------------------------------------------------------------------
   IF ST_GeometryType(p_geometry1) <> 'ST_LineString'
   THEN
      RAISE EXCEPTION 'geometry 1 must a single linestring, not %',ST_GeometryType(p_geometry1);
      
   END IF;
   
   IF NOT ST_IsSimple(p_geometry1)
   THEN
      RAISE EXCEPTION 'geometry 1 must be simple.';
      
   END IF;
   
   IF ST_IsClosed(p_geometry1)
   THEN
      RAISE EXCEPTION 'geometry 1 must not form a loop.';
      
   END IF;
   
   IF ST_GeometryType(p_geometry2) <> 'ST_LineString'
   THEN
      RAISE EXCEPTION 'geometry 2 must be single LRS linestring, not %',ST_GeometryType(p_geometry2);
      
   END IF;
   
   IF NOT dz_lrs.is_lrs(p_geometry2)
   THEN
      RAISE EXCEPTION 'geometry 2 must be single LRS linestring';
   
   END IF;
   
   IF NOT ST_IsSimple(p_geometry2)
   THEN
      RAISE EXCEPTION 'geometry 2 must be simple.';
      
   END IF;
   
   IF ST_IsClosed(p_geometry2)
   THEN
      RAISE EXCEPTION 'geometry 2 must not form a loop.';
      
   END IF;
   
   IF ST_SRID(p_geometry1) != ST_SRID(p_geometry2)
   THEN
      RAISE EXCEPTION 'geometries must have the same SRID.';
   
   END IF;
   
   --------------------------------------------------------------------------
   -- Step 20
   -- Collect the start and end points of the input geometry
   --------------------------------------------------------------------------
   sdo_input_start := ST_StartPoint(p_geometry1);
   sdo_input_end   := ST_EndPoint(p_geometry1);
   
   --------------------------------------------------------------------------
   -- Step 30
   -- Collect the start and end measure of the input geometry on the lrs
   --------------------------------------------------------------------------
   num_start_meas := ST_InterpolatePoint(
       p_geometry2
      ,sdo_input_start
   );
      
   num_end_meas := ST_InterpolatePoint(
       p_geometry2
      ,sdo_input_end
   );
   
   --------------------------------------------------------------------------
   -- Step 50
   -- Build the new LRS string from the measures
   --------------------------------------------------------------------------
   sdo_lrs_output := ST_AddMeasure(
       p_geometry1
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
    GEOMETRY
   ,GEOMETRY
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.overlay_measures(
    GEOMETRY
   ,GEOMETRY
) TO PUBLIC;

