CREATE OR REPLACE FUNCTION dz_lrs.append_flat(
    IN  p_geometry            GEOMETRY
   ,IN  p_append              GEOMETRY
) RETURNS GEOMETRY
IMMUTABLE
AS
$BODY$ 
DECLARE
   sdo_in     GEOMETRY;
   sdo_array  GEOMETRY[];
   
BEGIN

   ----------------------------------------------------------------------------
   -- Step 10
   -- Check over incoming parameters
   ----------------------------------------------------------------------------
   IF p_geometry IS NULL
   OR ST_IsEmpty(p_geometry)
   THEN
      RETURN p_append;
      
   END IF;
   
   IF p_append IS NULL
   OR ST_IsEmpty(p_append)
   THEN
      RETURN p_geometry;
      
   END IF;
   
   --------------------------------------------------------------------------
   -- Step 20
   -- Check for simple collect append scenarios
   --------------------------------------------------------------------------
   IF  ST_GeometryType(p_geometry) IN ('ST_Point','ST_LineString','ST_Polygon')
   AND ST_GeometryType(p_append)   IN ('ST_Point','ST_LineString','ST_Polygon')
   THEN
      RETURN ST_Collect(ARRAY[p_geometry,p_append]);
      
   END IF;
   
   IF  ST_NumGeometries(p_geometry) = 1
   AND ST_NumGeometries(p_append) = 1
   THEN
      RETURN ST_Collect(ARRAY[ST_GeometryN(p_geometry,1),ST_GeometryN(p_append,1)]);
   
   END IF;
   
   --------------------------------------------------------------------------
   -- Step 30
   -- Loop through and manually append components keeping the geometry flat
   --------------------------------------------------------------------------
   FOR i IN 1 .. ST_NumGeometries(p_geometry)
   LOOP
      sdo_in := ST_GeometryN(p_geometry,i);
      
      IF sdo_in IS NOT NULL
      AND NOT ST_IsEmpty(sdo_in)
      THEN
         sdo_array := array_append(sdo_array,sdo_in);
      
      END IF;
         
   END LOOP;
   
   FOR i IN 1 .. ST_NumGeometries(p_append)
   LOOP
      sdo_in := ST_GeometryN(p_append,i);
      
      IF sdo_in IS NOT NULL
      AND NOT ST_IsEmpty(sdo_in)
      THEN
         sdo_array := array_append(sdo_array,sdo_in);
      
      END IF;
         
   END LOOP;
   
   --------------------------------------------------------------------------
   -- Step 40
   -- Return the results
   --------------------------------------------------------------------------
   IF array_length(sdo_array,1) = 1
   THEN
      RETURN sdo_array[1];
   
   ELSE
      RETURN ST_Collect(sdo_array);
      
   END IF;
   
END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.append_flat(
    GEOMETRY
   ,GEOMETRY
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.append_flat(
    GEOMETRY
   ,GEOMETRY
) TO PUBLIC;

