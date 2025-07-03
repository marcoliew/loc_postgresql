docker exec -it pg-primary psql -U postgres -c "CREATE USER pg_exporter WITH PASSWORD 'securepassword' LOGIN;"
docker exec -it pg-primary psql -U postgres -c "GRANT pg_monitor TO pg_exporter;"

docker run -d --name postgres-exporter \
  -p 9187:9187 \
  -e DATA_SOURCE_NAME="postgresql://pg_exporter:securepassword@your_postgres_container:5432/postgres?sslmode=disable" \
  quay.io/prometheuscommunity/postgres-exporter

docker run -d --name prometheus \
  -p 9090:9090 \
  -v $(pwd)/conf/prometheus.yml:/etc/prometheus/prometheus.yml \
  --link postgres-exporter \
  prom/prometheus

docker run -d --name grafana \
  -p 3000:3000 \
  --link prometheus \
  grafana/grafana