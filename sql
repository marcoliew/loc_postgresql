# Import plain SQL dumps
psql -U user -d db < file.sql	

#Import binary dumps
pg_restore -U user -d db < file.dump	

# PowerShell uses < for future scripting operators, not input redirection
docker exec -i loc-postgres psql -U admin -d testdb < mydata.sql


Get-Content .\mydata.sql | docker exec -i loc-postgres psql -U admin -d testdb


# -Raw reads the file as a single string (faster for big files).
(Get-Content .\mydata.sql -Raw) | docker exec -i loc-postgre psql -U admin -d testdb


# copy to container

docker exec -i loc-postgres

# Step 1: Copy the file into the container
docker cp .\mydata.sql loc-postgres:/tmp/mydata.sql

# Step 2: Execute it from inside the container
docker exec -i loc-postgres psql -U admin -d testdb -f /tmp/mydata.sql


# query 
docker exec -i loc-postgres psql -U admin -d testdb -c "SELECT * FROM employees;"

# Stop services (keep data):
docker-compose stop

# Stop and delete containers (keep data):
docker-compose down

# Delete everything (including data):
docker-compose down -v


# Start the Services, Run this command in the same directory as your docker-compose.yml:

docker-compose up -d pgadmin  # Start only pgAdmin (if other containers are running)
# OR
docker-compose up -d         # Recreate all containers， -d runs containers in detached mode (background).

docker-compose down -v && docker-compose up -d

# Verify they’re running:

docker-compose ps

docker-compose restart postgres-primary

docker exec -it pg-primary bash


# trouble shooting

docker logs pg-primary --tail 100