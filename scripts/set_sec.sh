#!/bin/bash

# secrets-init.sh
# Usage: ./secrets-init.sh

# Create secrets directory (force recreate)
mkdir -p ./secrets
rm -f ./secrets/*.txt 2>/dev/null

# Prompt for passwords and Save secrets (force overwrite)
read -sp "Enter PostgreSQL admin password: " db_password; echo $db_pass > ./secrets/db_password.txt
echo
read -sp "Enter pgAdmin password: " pgadmin_password; echo $pgadmin_pass > ./secrets/pgadmin_password.txt
echo
read -sp "Enter replication password: " repl_pass; echo $repl_pass > ./secrets/repl_password.txt
echo

# Set permissions
chmod 600 ./secrets/*.txt

# Create .pgpass (force overwrite)
echo "pg-primary:5432:*:admin:${db_password}" > ~/.pgpass
chmod 600 ~/.pgpass

# Verification
echo -e "\n\033[32mSecrets configured successfully:\033[0m"
ls -l ./secrets/
echo -e "\n.pgpass created at: ~/.pgpass"

# echo "Primary: docker exec -it pg-primary psql -U admin"
# echo "Replica: docker exec -it pg-replica psql -U admin"
# echo "pgAdmin: http://localhost:5050"