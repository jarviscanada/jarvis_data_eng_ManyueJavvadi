#!/bin/sh

# Script usage:
# ./scripts/host_info.sh psql_host psql_port db_name psql_user psql_password

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Validate number of arguments
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  echo "Usage: ./scripts/host_info.sh psql_host psql_port db_name psql_user psql_password"
  exit 1
fi

# Collect hardware info
lscpu_out=$(lscpu)

hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | cut -d':' -f2 | xargs)
cpu_mhz=$(grep -m1 "cpu MHz" /proc/cpuinfo | awk '{print $4}')
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | sed 's/[^0-9]//g')
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(date -u "+%F %T")

# Build INSERT statement (id is SERIAL, so we skip it)
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, \"timestamp\") \
VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, $total_mem, '$timestamp');"

# Run INSERT through psql
export PGPASSWORD=$psql_password

psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit $?

