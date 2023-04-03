CREATE OR REPLACE FUNCTION dz_lrs.geom_segment_start_measure(
    IN  p_geometry          GEOMETRY
) RETURNS NUMERIC
IMMUTABLE
AS
$BODY$ 
DECLARE
   num_measure NUMERIC;
   
BEGIN
   RETURN ST_M(
      ST_StartPoint(p_geometry)
   );

END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.geom_segment_start_measure(
   GEOMETRY
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.geom_segment_start_measure(
   GEOMETRY
) TO PUBLIC;

