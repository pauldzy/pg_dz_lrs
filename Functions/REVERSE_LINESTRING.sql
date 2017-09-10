CREATE OR REPLACE FUNCTION dz_lrs.reverse_linestring(
    IN  pGeometry          geometry
) RETURNS geometry 
AS
$BODY$ 
DECLARE
   sdo_lrs_output    geometry;
   
BEGIN

   ----------------------------------------------------------------------------
   -- Step 10
   -- Check over incoming parameters
   ----------------------------------------------------------------------------
   IF ST_GeometryType(pGeometry)  <> 'ST_LineString'
   THEN
      RAISE EXCEPTION 'geometry must a single linestring';
      
   END IF;
   
   IF ST_M(
      ST_StartPoint(pGeometry)
   ) IS NULL
   THEN
      RETURN ST_Reverse(pGeometry);
      
   END IF;
   
   --------------------------------------------------------------------------
   -- Step 20
   -- Reverse the linestring taking measures along for a ride
   --------------------------------------------------------------------------
   SELECT
   ST_MakeLine(a.geom)
   INTO
   sdo_lrs_output
   FROM (
      SELECT
      aa.geom
      FROM (
         SELECT (ST_DumpPoints(
            pGeometry
         )).*
      ) aa
      ORDER BY
      aa.path[1] DESC
   ) a;
   
   --------------------------------------------------------------------------
   -- Step 30
   -- Return the results
   --------------------------------------------------------------------------
   RETURN sdo_lrs_output;
   
END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.reverse_linestring(
    geometry
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.reverse_linestring(
    geometry
) TO PUBLIC;

