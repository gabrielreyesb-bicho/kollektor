#!/usr/bin/env ruby

# Script para intentar encontrar o construir la DATABASE_URL de Heroku
# Basado en el nombre de la app de Heroku

puts "=" * 60
puts "BUSCANDO DATABASE_URL DE HEROKU"
puts "=" * 60
puts ""

# El nombre de tu app en Heroku era: kollektor-611834243c86
# (lo sabemos por la URL hardcodeada en production.rb)

heroku_app_name = "kollektor-611834243c86"

puts "Nombre de la app en Heroku: #{heroku_app_name}"
puts ""

# Heroku usa un formato estándar para las bases de datos
# Las bases de datos de Heroku Postgres tienen nombres como:
# - DATABASE_URL (la principal)
# - HEROKU_POSTGRESQL_<COLOR>_URL (bases adicionales)

puts "Opciones para obtener la DATABASE_URL:"
puts ""
puts "1. Si tienes acceso al dashboard de Render:"
puts "   - Ve a tu servicio en Render"
puts "   - Abre 'Environment'"
puts "   - Busca variables que contengan 'HEROKU' o 'herokuapp'"
puts "   - O busca variables de entorno antiguas"
puts ""

puts "2. Si tienes acceso a logs de Render:"
puts "   - Los logs pueden mostrar la DATABASE_URL al iniciar"
puts "   - Busca en logs antiguos antes de la migración"
puts ""

puts "3. Formato típico de DATABASE_URL de Heroku:"
puts "   postgres://[user]:[password]@[host]:[port]/[database]"
puts ""
puts "   Donde [host] suele ser algo como:"
puts "   - ec2-XX-XX-XX-XX.compute-1.amazonaws.com"
puts "   - o un hostname específico de Heroku Postgres"
puts ""

puts "4. Si tienes la URL pero no la password:"
puts "   - Heroku Postgres permite resetear la password"
puts "   - Pero necesitas acceso a la cuenta de Heroku"
puts ""

puts "5. Intentar desde la app en Render:"
puts "   - Si la app todavía tiene acceso, ejecuta en Render Shell:"
puts "     rails runner 'puts ENV.to_h.select { |k,v| v.to_s.include?(\"heroku\") || v.to_s.include?(\"amazonaws\") }'"
puts ""

puts "=" * 60
puts "ALTERNATIVA: Exportar desde Render si tiene datos"
puts "=" * 60
puts ""
puts "Si la app en Render ya tiene los datos migrados, puedes exportar desde ahí:"
puts ""
puts "  # En Render Shell o localmente con DATABASE_URL de Render:"
puts "  export DATABASE_URL='postgresql://kollektor_db_user:Uv3Gfx9IUT39Jgm50Q6SpcgMmFnOU3Lg@dpg-d6ibh67gi27c738dk8h0-a/kollektor_db'"
puts "  rails export_data:heroku_export"
puts ""
puts "Esto exportará todos los datos que estén en la base de datos de Render."
puts ""
