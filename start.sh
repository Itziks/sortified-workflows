#!/bin/bash

# Map Railway PostgreSQL variables to n8n format
if [ -n "$PGHOST" ]; then
    export DB_POSTGRESDB_HOST="$PGHOST"
    export DB_POSTGRESDB_PORT="$PGPORT"
    export DB_POSTGRESDB_DATABASE="$PGDATABASE"
    export DB_POSTGRESDB_USER="$PGUSER"
    export DB_POSTGRESDB_PASSWORD="$PGPASSWORD"
    
    echo "Database configuration mapped from Railway PostgreSQL variables"
    echo "Host: $DB_POSTGRESDB_HOST"
    echo "Port: $DB_POSTGRESDB_PORT"
    echo "Database: $DB_POSTGRESDB_DATABASE"
    echo "User: $DB_POSTGRESDB_USER"
elif [ -n "$DATABASE_URL" ]; then
    # Fallback: Parse DATABASE_URL if individual variables not available
    DB_URL_NO_PREFIX=${DATABASE_URL#postgresql://}
    DB_URL_NO_PREFIX=${DB_URL_NO_PREFIX#postgres://}
    
    USER_PASS_HOST_PORT_DB=$DB_URL_NO_PREFIX
    USER_PASS=${USER_PASS_HOST_PORT_DB%%@*}
    HOST_PORT_DB=${USER_PASS_HOST_PORT_DB#*@}
    
    export DB_POSTGRESDB_USER=${USER_PASS%%:*}
    export DB_POSTGRESDB_PASSWORD=${USER_PASS#*:}
    
    HOST_PORT=${HOST_PORT_DB%%/*}
    export DB_POSTGRESDB_DATABASE=${HOST_PORT_DB#*/}
    export DB_POSTGRESDB_HOST=${HOST_PORT%%:*}
    export DB_POSTGRESDB_PORT=${HOST_PORT#*:}
    
    echo "Database configuration parsed from DATABASE_URL"
fi

# Start n8n
exec n8n start