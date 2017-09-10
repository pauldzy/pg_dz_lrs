CREATE OR REPLACE FUNCTION dz_lrs.clip_geom_segment(
    IN  pGeometry          geometry
   ,IN  pStartMeasure      NUMERIC
   ,IN  pEndMeasure        NUMERIC
) RETURNS geometry
AS
$BODY$ 
DECLARE

BEGIN
   RETURN ST_GeometryN(
       ST_LocateBetween(
           pGeometry
          ,pStartMeasure
          ,pEndMeasure
          ,0
       )
      ,1
   );

END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.clip_geom_segment(
    geometry
   ,NUMERIC
   ,NUMERIC
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.clip_geom_segment(
    geometry
   ,NUMERIC
   ,NUMERIC
) TO PUBLIC;

