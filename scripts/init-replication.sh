#!/bin/bash
set -eo pipefail

REPL_PASSWORD=$(cat /run/secrets/repl_password)

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create essential databases (idempotent)
    CREATE DATABASE IF NOT EXISTS admin OWNER admin;
    CREATE DATABASE IF NOT EXISTS testdb OWNER admin;
    CREATE DATABASE IF NOT EXISTS postgres OWNER admin;
    
    -- Replication user management
    DO \$$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'repl_user') THEN
            CREATE ROLE repl_user WITH REPLICATION LOGIN ENCRYPTED PASSWORD '${REPL_PASSWORD}';
            RAISE NOTICE 'Created replication user';
        ELSE
            ALTER ROLE repl_user WITH PASSWORD '${REPL_PASSWORD}';
            RAISE NOTICE 'Updated replication user password';
        END IF;
    END \$$;

    -- Replication slot (physical)
    SELECT pg_create_physical_replication_slot('replica_slot', true)
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_replication_slots WHERE slot_name = 'replica_slot'
    );

    -- PostgreSQL configuration
    ALTER SYSTEM SET wal_level = 'replica';
    ALTER SYSTEM SET max_wal_senders = 10;
    ALTER SYSTEM SET max_replication_slots = 10;
    ALTER SYSTEM SET hot_standby = 'on';
    ALTER SYSTEM SET archive_mode = 'on';
    ALTER SYSTEM SET archive_command = 'test ! -f /var/lib/postgresql/archive/%f && cp %p /var/lib/postgresql/archive/%f';
    ALTER SYSTEM SET password_encryption = 'scram-sha-256';
    
    -- Ensure privileges
    GRANT ALL PRIVILEGES ON DATABASE admin TO admin;
    GRANT ALL PRIVILEGES ON DATABASE testdb TO admin;
    GRANT ALL PRIVILEGES ON DATABASE postgres TO admin;
EOSQL

# Apply configuration changes
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -c "SELECT pg_reload_conf();"

# Verification
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -c "\l"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -c "\du"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -c "SELECT * FROM pg_replication_slots;"