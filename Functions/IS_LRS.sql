CREATE OR REPLACE FUNCTION dz_lrs.is_lrs(
    IN  pGeometry          GEOMETRY
) RETURNS BOOLEAN
IMMUTABLE
AS
$BODY$ 
DECLARE

BEGIN

   IF ST_M(
      ST_PointN(
          ST_GeometryN(pGeometry,1)
         ,1
      )
   ) IS NULL
   OR ST_M(
      ST_PointN(
          ST_GeometryN(pGeometry,1)
         ,ST_NumPoints(ST_GeometryN(pGeometry,1))
      )
   ) IS NULL
   THEN
      RETURN FALSE;

   ELSE
      RETURN TRUE;

   END IF;

END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.is_lrs(
   geometry
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.is_lrs(
   geometry
) TO PUBLIC;

