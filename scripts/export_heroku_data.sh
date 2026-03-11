#!/bin/bash

# Script para exportar datos de Heroku
# Uso: ./scripts/export_heroku_data.sh [DATABASE_URL]

set -e

echo "=========================================="
echo "EXPORTADOR DE DATOS DE HEROKU"
echo "=========================================="
echo ""

# Verificar si se pasó DATABASE_URL como argumento
if [ -n "$1" ]; then
  export DATABASE_URL="$1"
  echo "✓ Usando DATABASE_URL proporcionada"
elif [ -n "$DATABASE_URL" ]; then
  echo "✓ Usando DATABASE_URL del entorno"
else
  echo "✗ DATABASE_URL no está configurada"
  echo ""
  echo "Uso:"
  echo "  ./scripts/export_heroku_data.sh 'postgres://user:pass@host:port/dbname'"
  echo ""
  echo "O configura la variable de entorno:"
  echo "  export DATABASE_URL='postgres://user:pass@host:port/dbname'"
  echo "  ./scripts/export_heroku_data.sh"
  exit 1
fi

# Verificar que pg_dump esté instalado
if ! command -v pg_dump &> /dev/null; then
  echo "✗ pg_dump no está instalado"
  echo ""
  echo "Instálalo con:"
  echo "  macOS: brew install postgresql"
  echo "  Ubuntu: sudo apt-get install postgresql-client"
  exit 1
fi

# Parsear DATABASE_URL
# Formato: postgres://user:password@host:port/database
DB_URL="$DATABASE_URL"

# Extraer componentes de la URL
DB_HOST=$(echo "$DB_URL" | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo "$DB_URL" | sed -n 's/.*:\([0-9]*\)\/.*/\1/p' || echo "5432")
DB_USER=$(echo "$DB_URL" | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo "$DB_URL" | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_NAME=$(echo "$DB_URL" | sed -n 's/.*\/\([^?]*\).*/\1/p')

# Crear directorio de exportación
EXPORT_DIR="tmp/heroku_export_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$EXPORT_DIR"

DUMP_FILE="$EXPORT_DIR/heroku_dump_$(date +%Y%m%d_%H%M%S).dump"

echo "Base de datos: $DB_HOST:$DB_PORT/$DB_NAME"
echo "Usuario: $DB_USER"
echo "Archivo de salida: $DUMP_FILE"
echo ""

# Exportar usando pg_dump
echo "Exportando base de datos..."
export PGPASSWORD="$DB_PASS"

pg_dump \
  --host="$DB_HOST" \
  --port="${DB_PORT:-5432}" \
  --username="$DB_USER" \
  --dbname="$DB_NAME" \
  --format=custom \
  --verbose \
  --no-owner \
  --no-acl \
  --file="$DUMP_FILE"

if [ $? -eq 0 ]; then
  echo ""
  echo "=========================================="
  echo "✓ EXPORTACIÓN EXITOSA"
  echo "=========================================="
  echo "Archivo: $DUMP_FILE"
  echo "Tamaño: $(du -h "$DUMP_FILE" | cut -f1)"
  echo ""
  echo "Para restaurar en Render:"
  echo "  pg_restore --clean --if-exists -d \$DATABASE_URL_RENDER $DUMP_FILE"
  echo ""
  echo "O para convertir a SQL plano:"
  echo "  pg_restore -f $DUMP_FILE.sql $DUMP_FILE"
else
  echo ""
  echo "✗ Error durante la exportación"
  exit 1
fi
