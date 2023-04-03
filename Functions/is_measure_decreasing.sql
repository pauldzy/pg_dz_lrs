CREATE OR REPLACE FUNCTION dz_lrs.is_measure_decreasing(
    IN  p_geometry          GEOMETRY
) RETURNS BOOLEAN
IMMUTABLE
AS
$BODY$ 
DECLARE
   num_start NUMERIC;
   num_end   NUMERIC;
   
BEGIN

   num_start := ST_M(ST_StartPoint(p_geometry));
   num_end   := ST_M(ST_EndPoint(p_geometry));
   
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
   GEOMETRY
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.is_measure_decreasing(
   GEOMETRY
) TO PUBLIC;

