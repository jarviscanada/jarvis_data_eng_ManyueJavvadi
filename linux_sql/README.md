# Linux Cluster Monitoring Agent

## Introduction
The Linux Cluster Monitoring Agent is a lightweight monitoring solution designed to collect hardware specifications and real-time usage metrics from Linux servers. The system is helpfull for, who manage a cluster of servers and require continuous insight into CPU, memory, and disk performance.

The agent consists of Bash scripts deployed on each host, which gather system information and store it in a centralized PostgreSQL database running in Docker. Git and GitFlow were used to manage development, and automation is achieved through Linux `crontab`. This project demonstrates shell scripting, process automation, Docker containerization, and basic database design.

---

## Quick Start

To set up the monitoring agent, follow these steps:

    # 1. Start a PostgreSQL instance using Docker
    ./scripts/psql_docker.sh create postgres password
    ./scripts/psql_docker.sh start

    # 2. Create database tables
    psql -h localhost -U postgres -d host_agent -f sql/ddl.sql

    # 3. Insert host hardware specifications (run once per host)
    ./scripts/host_info.sh localhost 5432 host_agent postgres password

    # 4. Insert resource usage (manual test)
    ./scripts/host_usage.sh localhost 5432 host_agent postgres password

    # 5. Automate monitoring with crontab (runs every minute)
    crontab -e

Add the following line to your crontab (ensure the path matches your specific directory):

    * * * * * bash /home/rocky/dev/jarvis_data_eng_ManyueJavvadi/linux_sql/scripts/host_usage.sh \ localhost 5432 host_agent postgres password >> /tmp/host_usage.log 2>&1

---

## Implementation

### Architecture
The system architecture consists of:
* **Three Linux hosts** running the monitoring agent scripts.
* **A central PostgreSQL database** running in a Docker container.
* **Two agent scripts:**
    * `host_info.sh`: Collects static hardware details.
    * `host_usage.sh`: Collects usage metrics every minute.

```text
                    +--------------------------------+
                    |  PostgreSQL (Docker Container) |
                    |  Container: jrvs                |
                    |  Database: host_agent           |
                    +---------------+----------------+
                                    ^
                                    | INSERTs (host_info, host_usage)
                                    |
       +----------------------------+----------------------------+
       |                            |                            |
+--------------+            +---------------+            +---------------+
|  Linux Host  |            |  Linux Host   |            |  Linux Host   |
|   Host A     |            |   Host B      |            |   Host C      |
|--------------|            |---------------|            |---------------|
| host_info.sh |            | host_info.sh  |            | host_info.sh  |
| (run once)   |            | (run once)    |            | (run once)    |
| host_usage.sh|            | host_usage.sh |            | host_usage.sh |
| (cron: every |            | (cron: every  |            | (cron: every  |
|  1 minute)   |            |  1 minute)    |            |  1 minute)    |
+--------------+            +---------------+            +---------------+
       |                            |                            |
       +----------------------------+----------------------------+
                                    |
                       Centralized metrics collection
```

Cron example (per host):
```bash
* * * * * bash /path/to/host_usage.sh localhost 5432 host_agent postgres password >> /tmp/host_usage.log 2>&1
```

### Scripts

#### 1. `psql_docker.sh`
Manages the PostgreSQL Docker container lifecycle (Create, Start, Stop).

**Usage:**

    ./scripts/psql_docker.sh create db_user db_password
    ./scripts/psql_docker.sh start
    ./scripts/psql_docker.sh stop

**Features:**
* Creates a container with a persistent volume.
* Starts/stops existing containers.
* Prevents duplicate container creation.
* Uses environment variables for secure password handling.

#### 2. `host_info.sh`
Collects static machine information such as CPU model, cache size, memory, hostname, and architecture using commands like `lscpu`, `vmstat`, and `hostname`. This script is executed **once** per host.

**Usage:**

    ./scripts/host_info.sh localhost 5432 host_agent postgres password

#### 3. `host_usage.sh`
Collects live system metrics including free memory, CPU idle %, CPU kernel %, disk usage, and available storage. This script is executed **every minute** via `crontab`.

**Usage:**

    ./scripts/host_usage.sh localhost 5432 host_agent postgres password

#### 4. `crontab`
Automates the execution of `host_usage.sh`.

**Example entry:**

    * * * * * bash /path/to/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log

#### 5. `queries.sql`
Contains SQL queries used for reporting and resource analysis (e.g., calculating average CPU idle per host, tracking memory trends, etc.).

---

## Database Modeling

The database `host_agent` contains two main tables:

### `host_info` Table
Stores static hardware specifications.

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | SERIAL (PK) | Unique identifier for each host |
| `hostname` | VARCHAR | Fully qualified hostname |
| `cpu_number` | INT2 | Number of CPUs |
| `cpu_architecture` | VARCHAR | CPU architecture (e.g., x86_64) |
| `cpu_model` | VARCHAR | Model name |
| `cpu_mhz` | FLOAT8 | CPU clock speed |
| `l2_cache` | INT4 | L2 cache size (KB) |
| `total_mem` | INT4 | Total memory (MB) |
| `timestamp` | TIMESTAMP | Time of recording (UTC) |

### `host_usage` Table
Stores real-time usage metrics.

| Column | Type | Description |
| :--- | :--- | :--- |
| `timestamp` | TIMESTAMP | When the metrics were recorded |
| `host_id` | INT (FK) | References `host_info(id)` |
| `memory_free` | INT | Free memory (MB) |
| `cpu_idle` | INT2 | CPU idle percentage |
| `cpu_kernel` | INT2 | CPU usage in kernel mode (%) |
| `disk_io` | INT4 | Disk I/O operations |
| `disk_available` | INT4 | Available disk space (MB) |

---

## Test

Testing was conducted through the following steps:

1.  **Manual Execution:** Running each script manually to verify correctness.
2.  **Docker Validation:** Checking container status using `docker ps`.
3.  **Database Validation:** Confirming table creation using `\dt` inside the `psql` CLI.
4.  **Data Verification:** Running insertions and checking results using SQL queries:
    
        SELECT * FROM host_info;
        SELECT * FROM host_usage ORDER BY timestamp DESC LIMIT 5;

5.  **Automation Test:** Verifying `crontab` automation by checking that new rows are added to the database every minute.

---

## Deployment

The system is deployed using:
* **GitHub:** For version control (GitFlow workflow).
* **Docker:** For provisioning the PostgreSQL database.
* **Crontab:** For automated time-based execution.
* **Bash Scripts:** For data collection.
* **PSQL CLI:** For database operations.

(See Quick Start section for detailed deployment steps).

---

## Improvements

* **Error Handling:** Add better error handling and logging to scripts to debug issues easier.
* **Systemd Service:** Convert the monitoring agent into a systemd service instead of relying on `crontab`.
* **New Metrics:** Extend metrics to include network traffic and CPU temperature.
* **API:** Build REST APIs for remote querying of metrics.
* **Visualization:** Add visualization tools like Grafana or custom dashboards to display the data.
