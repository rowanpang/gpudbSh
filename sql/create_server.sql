CREATE EXTENSION zdb_fdw;

CREATE SERVER zdb_server  DATA WRAPPER  zdb_fdw;
