-- ddl.sql
-- Initialize tables for host_agent database

-- host_info: hardware specs per host
CREATE TABLE IF NOT EXISTS host_info (
  id               SERIAL       PRIMARY KEY,
  hostname         VARCHAR      NOT NULL UNIQUE,
  cpu_number       SMALLINT     NOT NULL,
  cpu_architecture VARCHAR      NOT NULL,
  cpu_model        VARCHAR      NOT NULL,
  cpu_mhz          DOUBLE PRECISION NOT NULL,
  l2_cache         INTEGER      NOT NULL,
  total_mem        INTEGER      NOT NULL,
  "timestamp"      TIMESTAMP    NOT NULL
);

-- host_usage: periodic resource usage per host
CREATE TABLE IF NOT EXISTS host_usage (
  "timestamp"      TIMESTAMP    NOT NULL,
  host_id          INTEGER      NOT NULL,
  memory_free      INTEGER      NOT NULL,
  cpu_idle         SMALLINT     NOT NULL,
  cpu_kernel       SMALLINT     NOT NULL,
  disk_io          INTEGER      NOT NULL,
  disk_available   INTEGER      NOT NULL,
  CONSTRAINT host_usage_host_info_fk
    FOREIGN KEY (host_id) REFERENCES host_info(id)
);

