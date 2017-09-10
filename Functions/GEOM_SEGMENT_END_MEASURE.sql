CREATE OR REPLACE FUNCTION dz_lrs.geom_segment_end_measure(
    IN  pGeometry          GEOMETRY
) RETURNS NUMERIC
AS
$BODY$ 
DECLARE

BEGIN
   RETURN ST_M(
      ST_EndPoint(pGeometry)
   );

END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.geom_segment_end_measure(
   geometry
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.geom_segment_end_measure(
   geometry
) TO PUBLIC;

