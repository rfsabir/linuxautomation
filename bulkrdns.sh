#!/bin/bash

# MySQL connection details (hardcoded)
MYSQL_HOST="localhost"
MYSQL_USER="your_mysql_user"
MYSQL_PASSWORD="your_mysql_password"
MYSQL_DB="your_pdns_database"

# Usage function
usage() {
  echo "Usage: $0 <csv_file>"
  exit 1
}

# Check for required arguments
if [ "$#" -ne 1 ]; then
  usage
fi

CSV_FILE=$1

# Check if the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
  echo "Error: CSV file not found!"
  exit 1
fi

# Read the CSV file and insert records into MySQL
while IFS=',' read -r dname address ttl
do
  # Skip the header line
  if [ "$dname" == "dname" ]; then
    continue
  fi

  # Create the reverse DNS PTR record
  rdns_ptr=$(echo $address | awk -F. '{print $4"."$3"."$2"."$1".in-addr.arpa"}')

  # Insert into MySQL
  mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" <<EOF
INSERT INTO records (domain_id, name, type, content, ttl, prio, change_date)
SELECT id, '$rdns_ptr', 'PTR', '$dname', $ttl, NULL, UNIX_TIMESTAMP()
FROM domains
WHERE name = 'in-addr.arpa';
EOF

  if [ $? -eq 0 ]; then
    echo "Inserted: $dname, $address, $ttl"
  else
    echo "Failed to insert: $dname, $address, $ttl"
  fi

done < "$CSV_FILE"
