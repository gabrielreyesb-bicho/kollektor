# Cómo Encontrar la DATABASE_URL de Heroku

**Situación**: Los datos están en Heroku, no en Render. Necesitas la DATABASE_URL de Heroku para exportarlos.

## 🔍 Opción 1: Verificar en Render (Si la app todavía tiene acceso)

Aunque la app en Render ahora use su propia base de datos, es posible que todavía tenga variables de entorno con la URL de Heroku guardadas.

### Usando el endpoint que creamos:

1. **Haz deploy de los cambios** (el controlador `DataExportController`)

2. **Abre en tu navegador**:
   ```
   https://tu-app.onrender.com/data_export/check
   ```

3. **Revisa el JSON** - Busca la sección `possible_heroku_vars`. Si hay alguna variable que contenga una URL de PostgreSQL que no sea de Render (no tenga `dpg-`), esa podría ser la de Heroku.

### Verificar manualmente en Render Dashboard:

1. Ve a tu servicio en Render
2. Abre "Environment" 
3. **Revisa TODAS las variables de entorno** - Busca:
   - Variables que contengan "HEROKU" en el nombre
   - Variables que contengan URLs de PostgreSQL que NO sean de Render
   - Variables antiguas que puedan haber quedado de la migración

## 📧 Opción 2: Buscar en Emails de Heroku

Heroku a veces envía emails con información de configuración:

1. Busca en tu email por:
   - "Heroku Postgres"
   - "kollektor-611834243c86"
   - "DATABASE_URL"
   - Emails de Heroku de cuando configuraste la app

2. Los emails pueden contener la URL completa o información útil

## 📁 Opción 3: Buscar en Archivos Locales

Busca en tu computadora:

```bash
# Buscar archivos .env
find . -name ".env*" -type f

# Buscar en archivos de texto
grep -r "postgres.*amazonaws" .
grep -r "postgres.*ec2-" .
grep -r "kollektor-611834243c86" .
```

Lugares comunes:
- `~/.env` (en tu home)
- `~/Documents/` (notas, documentación)
- Historial de terminal (si guardaste comandos)
- Archivos de configuración de IDEs (VS Code, etc.)

## 🔐 Opción 4: Contactar Soporte de Heroku

Aunque perdiste el 2FA, Heroku puede ayudarte si proporcionas:

1. **Email de la cuenta de Heroku**
2. **Nombre de la app**: `kollektor-611834243c86`
3. **Información de verificación**:
   - Últimos 4 dígitos de la tarjeta de crédito asociada
   - Dirección de facturación
   - Fecha aproximada de creación de la cuenta
   - Cualquier otra información que puedan usar para verificar tu identidad

**Contacto de Heroku**:
- Email: support@heroku.com
- Dashboard: https://help.heroku.com (aunque necesitas login)

## 🔑 Opción 5: Backup Codes de Heroku

Si guardaste los **backup codes** de Heroku cuando configuraste el 2FA:
- Úsalos para acceder a tu cuenta
- Luego puedes obtener la DATABASE_URL con: `heroku config:get DATABASE_URL -a kollektor-611834243c86`

## 🛠️ Opción 6: Si Tienes Acceso a GitHub/GitLab CI/CD

Si tu app tenía CI/CD configurado:
- Revisa los secrets/variables de entorno en GitHub/GitLab
- Puede que la DATABASE_URL esté guardada ahí

## 📝 Formato de la DATABASE_URL de Heroku

La URL de Heroku típicamente se ve así:

```
postgres://[user]:[password]@[host]:[port]/[database]
```

Donde `[host]` suele ser:
- `ec2-XX-XX-XX-XX.compute-1.amazonaws.com` (AWS)
- O un hostname específico de Heroku Postgres

**Ejemplo**:
```
postgres://u123abc:password123@ec2-54-123-45-67.compute-1.amazonaws.com:5432/db123abc
```

## ✅ Una vez que tengas la URL

Una vez que encuentres la DATABASE_URL de Heroku:

```bash
# Exportar a JSON
export DATABASE_URL='postgres://user:pass@host:port/dbname'
rails export_data:heroku_export

# O exportar dump completo
rails export_data:pg_dump
```

Los archivos se guardarán en `tmp/heroku_export/`

## 🚨 Si NO puedes encontrar la URL

Si después de intentar todas estas opciones no encuentras la URL:

1. **Contacta a soporte de Heroku** - Es tu mejor opción
2. **Verifica si Heroku tiene backups automáticos** - A veces Heroku guarda backups que puedes descargar
3. **Considera si los datos son críticos** - Si son muy importantes, vale la pena el esfuerzo de recuperar acceso
