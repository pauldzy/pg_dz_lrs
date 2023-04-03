CREATE OR REPLACE FUNCTION dz_lrs.geom_segment_end_measure(
    IN  p_geometry          GEOMETRY
) RETURNS NUMERIC
IMMUTABLE
AS
$BODY$ 
DECLARE

BEGIN
   RETURN ST_M(
      ST_EndPoint(p_geometry)
   );

END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.geom_segment_end_measure(
   GEOMETRY
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.geom_segment_end_measure(
   GEOMETRY
) TO PUBLIC;

