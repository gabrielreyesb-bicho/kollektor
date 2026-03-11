# Instrucciones para Exportar Datos desde Render (Sin Shell)

Como no tienes acceso a Render Shell, he creado endpoints HTTP que puedes usar desde tu navegador.

## Paso 1: Hacer commit y deploy

Primero, haz commit de los cambios y súbelos a Render:

```bash
git add .
git commit -m "Add data export endpoints"
git push
```

Render hará el deploy automáticamente.

## Paso 2: Configurar token de seguridad (Opcional pero recomendado)

En el dashboard de Render:
1. Ve a tu servicio
2. Abre "Environment"
3. Agrega una variable:
   - Key: `EXPORT_TOKEN`
   - Value: (elige un token seguro, ej: `mi_token_secreto_123`)

**Nota**: Si no configuras el token, el endpoint usará un token por defecto: `change_this_token_in_production`

## Paso 3: Verificar qué datos hay

Una vez que Render termine el deploy, abre en tu navegador:

```
https://tu-app.onrender.com/data_export/check
```

Esto te mostrará un JSON con el conteo de registros de cada tipo. Ejemplo:

```json
{
  "users": 5,
  "albums": 150,
  "authors": 45,
  "genres": 20,
  ...
}
```

## Paso 4: Exportar todos los datos

Para descargar todos los datos como archivo JSON:

```
https://tu-app.onrender.com/data_export/all?token=TU_TOKEN_AQUI
```

**Reemplaza `TU_TOKEN_AQUI` con:**
- El token que configuraste en `EXPORT_TOKEN`, o
- `change_this_token_in_production` si no configuraste ninguno

El navegador descargará un archivo JSON con todos los datos.

## Paso 5: Procesar el archivo JSON

Una vez descargado el archivo, puedes:

1. **Verificar que tenga todos los datos**: Abre el JSON y verifica que tenga todos los registros esperados

2. **Si necesitas importar a otra base de datos**: Usa el task de importación:
   ```bash
   # Copia el JSON a tmp/data_export/ con los nombres correctos
   # Luego ejecuta:
   rails import_data:from_json
   ```

## Estructura del archivo exportado

El JSON exportado tiene esta estructura:

```json
{
  "exported_at": "2025-01-XX...",
  "database_info": { ... },
  "data": {
    "users": { "count": 5, "records": [...] },
    "albums": { "count": 150, "records": [...] },
    "authors": { "count": 45, "records": [...] },
    ...
  }
}
```

## Troubleshooting

### Error 401 (Unauthorized)
- Verifica que estés usando el token correcto
- Si no configuraste `EXPORT_TOKEN`, usa: `change_this_token_in_production`

### Error 500
- Revisa los logs de Render para ver el error específico
- Puede ser un problema de conexión a la base de datos

### El archivo JSON está vacío
- Verifica primero con `/data_export/check` que haya datos
- Si no hay datos, significa que la base de datos de Render está vacía y necesitas exportar desde Heroku

## ¿Qué hacer si no hay datos en Render?

Si el endpoint `/data_export/check` muestra que no hay datos (todos en 0), entonces necesitas:

1. **Encontrar la DATABASE_URL de Heroku** (ver `HEROKU_DATA_EXPORT.md`)
2. **O contactar a soporte de Heroku** para recuperar acceso
