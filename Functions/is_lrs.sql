CREATE OR REPLACE FUNCTION dz_lrs.is_lrs(
    IN  p_geometry          GEOMETRY
) RETURNS BOOLEAN
IMMUTABLE
AS
$BODY$ 
DECLARE

BEGIN

   IF ST_M(
      ST_PointN(
          ST_GeometryN(p_geometry,1)
         ,1
      )
   ) IS NULL
   OR ST_M(
      ST_PointN(
          ST_GeometryN(p_geometry,1)
         ,ST_NumPoints(ST_GeometryN(p_geometry,1))
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
   GEOMETRY
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.is_lrs(
   GEOMETRY
) TO PUBLIC;

