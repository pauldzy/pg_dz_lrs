# pg_dz_lrs
PostgreSQL PostGIS port of useful Oracle Spatial LRS tools.

The LRS functions set between Oracle Spatial and PostGIS differs a bit leading one to put together some helper functions to aid in the porting of logic.

This includes a port of [my Oracle logic](https://github.com/pauldzy/DZ_LRS/blob/56aa64711f271905b2a84df5965093cc62ad46a4/Packages/DZ_LRS_MAIN.pks#L105) to intersect LRS linestrings by polygons.  PostGIS does not provide this functionality at this time so it may be useful.
