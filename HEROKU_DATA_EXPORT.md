# Guía para Exportar Datos de Heroku

Esta guía te ayudará a extraer todos los datos de tu base de datos de Heroku cuando no tienes acceso directo a la cuenta.

## ⚠️ Situación Actual

Tienes la DATABASE_URL de Render:
```
postgresql://kollektor_db_user:Uv3Gfx9IUT39Jgm50Q6SpcgMmFnOU3Lg@dpg-d6ibh67gi27c738dk8h0-a/kollektor_db
```

**Primero verifica**: ¿Los datos ya están en Render? Si es así, puedes exportar directamente desde ahí.

## 🚀 PASO 1: Verificar si los datos ya están en Render

**ANTES de buscar la URL de Heroku**, verifica si los datos ya están en tu base de datos de Render:

```bash
# Usar la DATABASE_URL de Render que ya tienes
export DATABASE_URL='postgresql://kollektor_db_user:Uv3Gfx9IUT39Jgm50Q6SpcgMmFnOU3Lg@dpg-d6ibh67gi27c738dk8h0-a/kollektor_db'

# Ejecutar el script inteligente que verifica y exporta
rails runner scripts/export_from_render_or_heroku.rb
```

Este script:
- ✅ Verifica qué datos hay en la base de datos actual
- ✅ Te muestra cuántos registros hay de cada tipo
- ✅ Exporta todo a archivos JSON

**Si los datos ya están en Render**, ¡listo! Ya tienes todo exportado.

**Si NO están todos los datos**, continúa con las opciones siguientes.

---

## Opciones Disponibles

### Opción 1: Si tienes la DATABASE_URL de Heroku guardada

Si en algún momento guardaste la `DATABASE_URL` de Heroku (en un archivo `.env`, notas, o en la configuración de Render), puedes usarla directamente.

#### Método A: Exportar a JSON (Recomendado para datos pequeños/medianos)

```bash
# Configurar la DATABASE_URL de Heroku
export DATABASE_URL='postgres://user:password@host:port/database'

# Ejecutar el exportador
rails export_data:heroku_export
```

Los archivos JSON se guardarán en `tmp/heroku_export/`

#### Método B: Exportar dump completo de PostgreSQL (Recomendado para bases grandes)

```bash
# Configurar la DATABASE_URL de Heroku
export DATABASE_URL='postgres://user:password@host:port/database'

# Crear dump
rails export_data:pg_dump
```

O usar el script shell:

```bash
./scripts/export_heroku_data.sh 'postgres://user:password@host:port/database'
```

### Opción 2: Desde Render si todavía apunta a Heroku

Si tu app en Render todavía tiene configurada la `DATABASE_URL` de Heroku (antes de migrar completamente), puedes ejecutar el exportador desde Render:

1. Ve al dashboard de Render
2. Abre tu servicio
3. Ve a "Shell" o "Console"
4. Ejecuta:

```bash
rails export_data:heroku_export
```

O si prefieres el dump completo:

```bash
rails export_data:pg_dump
```

Los archivos se crearán en el servidor de Render. Luego puedes descargarlos usando `scp` o desde el panel de Render.

### Opción 3: Usar el script Ruby directamente

```bash
# Configurar DATABASE_URL
export DATABASE_URL='postgres://user:password@host:port/database'

# Ejecutar
rails runner scripts/export_heroku_data.rb
```

## Cómo encontrar la DATABASE_URL de Heroku

### Si tienes acceso a la app en Render:

1. Ve al dashboard de Render
2. Selecciona tu servicio
3. Ve a "Environment" 
4. Busca la variable `DATABASE_URL` - si todavía apunta a Heroku, úsala

### Si tienes acceso a logs o código antiguo:

Busca en:
- Archivos `.env` locales
- Historial de git (aunque no debería estar commitado)
- Notas/documentación personal
- Variables de entorno en otros servicios (como GitHub Actions, CI/CD)

### Si tienes acceso parcial a Heroku:

Aunque perdiste el 2FA, intenta:

1. **Recuperar backup codes**: Si guardaste los códigos de respaldo de Heroku, úsalos
2. **Contactar soporte de Heroku**: Proporciona:
   - Email de la cuenta
   - Nombre de la app
   - Últimos 4 dígitos de la tarjeta de crédito asociada
   - Información de facturación
3. **Verificar email**: A veces Heroku envía la `DATABASE_URL` en emails de configuración

## Importar Datos a Render

Una vez que tengas los datos exportados:

### Si exportaste a JSON:

```bash
# En tu entorno local o en Render
rails import_data:from_json
```

### Si exportaste un dump de PostgreSQL:

```bash
# Configurar DATABASE_URL de Render
export DATABASE_URL_RENDER='postgres://user:pass@render-host:port/dbname'

# Restaurar
pg_restore --clean --if-exists -d "$DATABASE_URL_RENDER" tmp/heroku_export/heroku_dump_*.dump
```

## Verificar qué datos se exportaron

Los scripts exportan:
- ✅ Users (sin passwords)
- ✅ Albums
- ✅ Authors
- ✅ Genres
- ✅ Countries
- ✅ Series
- ✅ Actors
- ✅ Notifications
- ✅ Active Storage metadata (attachments y blobs)

**Nota importante sobre Active Storage**: Los metadatos se exportan, pero los archivos físicos (imágenes, etc.) están en S3. Si usas el mismo bucket de S3 en Render, los archivos seguirán siendo accesibles. Si no, necesitarás migrar los archivos de S3 también.

## Troubleshooting

### Error: "DATABASE_URL no está configurada"
- Verifica que la variable esté configurada: `echo $DATABASE_URL`
- Asegúrate de usar comillas simples para evitar que el shell interprete caracteres especiales

### Error: "pg_dump: command not found"
- Instala PostgreSQL client:
  - macOS: `brew install postgresql`
  - Ubuntu: `sudo apt-get install postgresql-client`

### Error de conexión
- Verifica que la URL sea correcta
- Verifica que la base de datos de Heroku todavía esté activa
- Verifica que no haya restricciones de firewall

### Error: "relation does not exist"
- Algunos modelos pueden no existir en tu versión de la base de datos
- Los scripts ignoran estos errores y continúan con los demás modelos

## Siguiente Paso

Una vez que tengas los datos exportados, puedes:
1. Importarlos a tu nueva base de datos en Render
2. Verificar que todo esté correcto
3. Finalmente cerrar la cuenta de Heroku
