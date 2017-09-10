CREATE OR REPLACE FUNCTION dz_lrs.geom_segment_start_measure(
    IN  pGeometry          geometry
) RETURNS NUMERIC
AS
$BODY$ 
DECLARE
   num_measure NUMERIC;
   
BEGIN
   RETURN ST_M(
      ST_StartPoint(pGeometry)
   );

END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.geom_segment_start_measure(
   geometry
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.geom_segment_start_measure(
   geometry
) TO PUBLIC;

