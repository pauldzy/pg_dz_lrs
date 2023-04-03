CREATE OR REPLACE FUNCTION dz_lrs.clip_geom_segment(
    IN  p_geometry          GEOMETRY
   ,IN  p_start_measure     NUMERIC
   ,IN  p_end_measure       NUMERIC
) RETURNS GEOMETRY
IMMUTABLE
AS
$BODY$ 
DECLARE

BEGIN
   RETURN ST_GeometryN(
       ST_LocateBetween(
           p_geometry
          ,p_start_measure
          ,p_end_measure
          ,0
       )
      ,1
   );

END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.clip_geom_segment(
    GEOMETRY
   ,NUMERIC
   ,NUMERIC
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.clip_geom_segment(
    GEOMETRY
   ,NUMERIC
   ,NUMERIC
) TO PUBLIC;

