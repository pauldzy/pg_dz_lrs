CREATE OR REPLACE FUNCTION dz_lrs.break_closed_lrs(
    IN  p_geometry            GEOMETRY
) RETURNS GEOMETRY
IMMUTABLE
AS
$BODY$ 
DECLARE
   sdo_in     GEOMETRY;
   sdo_output GEOMETRY;
   num_start  NUMERIC;
   num_end    NUMERIC;
   num_mid    NUMERIC;
   sdo_split1 GEOMETRY;
   sdo_split2 GEOMETRY;
   
BEGIN

   ----------------------------------------------------------------------------
   -- Step 10
   -- Check over incoming parameters
   ----------------------------------------------------------------------------
   IF NOT dz_lrs.is_lrs(p_geometry)
   THEN
      RAISE EXCEPTION 'input geometry must be LRS geometry.';
      
   END IF;
   
   IF ST_GeometryType(p_geometry) IN ('ST_Point','ST_MultiPoint','ST_Polygon','ST_MultiPolygon')
   THEN
      RETURN NULL;
      
   ELSIF ST_GeometryType(p_geometry) = 'ST_LineString'
   AND NOT ST_IsClosed(p_geometry)
   THEN
      RETURN p_geometry;
      
   END IF;
      
   --------------------------------------------------------------------------
   -- Step 20
   -- Loop through components, breaking loops if found
   --------------------------------------------------------------------------
   FOR i IN 1 .. ST_NumGeometries(p_geometry)
   LOOP
      sdo_in := ST_GeometryN(p_geometry,i);
      
      IF ST_GeometryType(sdo_in) = 'ST_LineString'
      THEN
         IF NOT dz_lrs.is_lrs(sdo_in)
         THEN
            RAISE EXCEPTION 'component is not LRS linestring. geom: %',i;
            
         END IF;
         
         IF NOT ST_IsSimple(sdo_in)
         THEN
            RAISE EXCEPTION 'components must all be simple LRS linestrings. geom: %',i;
            
         END IF;
      
         IF ST_IsClosed(sdo_in)
         THEN
            num_start := ST_M(ST_StartPoint(sdo_in));
            num_end   := ST_M(ST_EndPoint(sdo_in));
            
            IF num_start > num_end
            THEN
               num_end := num_start;
               num_start := ST_M(ST_EndPoint(sdo_in));
               
            END IF;
            
            num_mid := num_start + ((num_end - num_start) / 2);
            
            sdo_split1 := ST_GeometryN(ST_LocateBetween(
                sdo_in
               ,num_start
               ,num_mid
            ),1);
            
            sdo_split2 := ST_GeometryN(ST_LocateBetween(
                sdo_in
               ,num_mid
               ,num_end
            ),1);
            
            sdo_output := dz_lrs.append_flat(sdo_output,sdo_split1);
            sdo_output := dz_lrs.append_flat(sdo_output,sdo_split2);
            
         ELSE
            sdo_output := dz_lrs.append_flat(sdo_output,sdo_in);
            
         END IF;
   
      END IF;
   
   END LOOP;

   --------------------------------------------------------------------------
   -- Step 30
   -- Return the results
   --------------------------------------------------------------------------
   RETURN sdo_output;
   
END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.break_closed_lrs(
    GEOMETRY
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.break_closed_lrs(
    GEOMETRY
) TO PUBLIC;

