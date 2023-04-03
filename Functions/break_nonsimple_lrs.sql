CREATE OR REPLACE FUNCTION dz_lrs.break_nonsimple_lrs(
    IN  p_geometry            GEOMETRY
) RETURNS GEOMETRY
IMMUTABLE
AS
$BODY$ 
DECLARE
   rec        RECORD;
   int_index  INTEGER;
   sdo_line   GEOMETRY;
   sdo_last   GEOMETRY;
   sdo_check  GEOMETRY;
   sdo_out    GEOMETRY;
   sdo_items  GEOMETRY[];
   
BEGIN

   ----------------------------------------------------------------------------
   -- Step 10
   -- Check over incoming parameters
   ----------------------------------------------------------------------------
   IF ST_GeometryType(p_geometry) = 'ST_LineString'
   THEN
      IF NOT dz_lrs.is_lrs(p_geometry)
      THEN
         RAISE EXCEPTION 'input must be single LRS linestring.';
      
      END IF;
      
      IF ST_IsSimple(p_geometry)
      THEN
         RETURN p_geometry;
      
      END IF;
      
   ELSE
      RAISE EXCEPTION 'input must be single LRS linestring. %',ST_GeometryType(p_geometry);
   
   END IF;
      
   --------------------------------------------------------------------------
   -- Step 20
   -- Break the line string into simple components
   --------------------------------------------------------------------------
   FOR rec IN SELECT (ST_DumpPoints(p_geometry)).*
   LOOP
      IF rec.path[1] = 1
      THEN
         sdo_line := rec.geom;
         
      ELSE
         sdo_check := ST_MakeLine(sdo_line,rec.geom);

         IF ST_IsSimple(sdo_check)
         THEN
            sdo_line := sdo_check;

         ELSE
            sdo_items := array_append(sdo_items,sdo_line);
            sdo_line  := ST_MakeLine(sdo_last,rec.geom);

         END IF;

      END IF;
      
      sdo_last := rec.geom;
   
   END LOOP;
   
   sdo_items := array_append(sdo_items,sdo_line);
   
   --------------------------------------------------------------------------
   -- Step 30
   -- Return the results
   --------------------------------------------------------------------------
   FOR i IN 1 .. array_length(sdo_items,1)
   LOOP
      sdo_out := dz_lrs.append_flat(sdo_out,sdo_items[i]);
      
   END LOOP;
   
   RETURN sdo_out;
   
END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION dz_lrs.break_nonsimple_lrs(
    GEOMETRY
) OWNER TO dz_lrs;

GRANT EXECUTE ON FUNCTION dz_lrs.break_nonsimple_lrs(
    GEOMETRY
) TO PUBLIC;

