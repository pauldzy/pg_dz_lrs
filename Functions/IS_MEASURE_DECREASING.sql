CREATE OR REPLACE FUNCTION dz_lrs.is_measure_decreasing(
    IN  pGeometry          GEOMETRY
) RETURNS BOOLEAN
IMMUTABLE
AS
$BODY$ 
DECLARE
   num_start NUMERIC;
   num_end   NUMERIC;
   
BEGIN

   num_start := ST_M(ST_StartPoint(pGeometry));
   num_end   := ST_M(ST_EndPoint(pGeometry));
   
   IF num_start IS NULL
   OR num_end IS NULL
   THEN
      RETURN NULL;

   ELSIF num_start > num_end
   THEN
      RETURN TRUE;

   ELSE
      RETURN FALSE;
      
   END IF;

END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.is_measure_decreasing(
   geometry
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.is_measure_decreasing(
   geometry
) TO PUBLIC;

