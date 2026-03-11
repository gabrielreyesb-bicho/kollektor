#!/usr/bin/env ruby

# Script para verificar variables de entorno en Render
# Ejecutar en Render Shell: rails runner scripts/check_render_env.rb

puts "=" * 60
puts "VARIABLES DE ENTORNO EN RENDER"
puts "=" * 60
puts ""

# Buscar cualquier variable que pueda contener info de Heroku
heroku_vars = ENV.to_h.select do |k, v|
  v.to_s.downcase.include?('heroku') || 
  v.to_s.include?('amazonaws') ||
  v.to_s.include?('ec2-') ||
  k.to_s.downcase.include?('heroku')
end

if heroku_vars.any?
  puts "✓ Variables encontradas que pueden contener info de Heroku:"
  puts ""
  heroku_vars.each do |key, value|
    # Enmascarar passwords
    masked_value = value.gsub(/:[^:@]+@/, ':****@')
    puts "  #{key}: #{masked_value}"
  end
else
  puts "✗ No se encontraron variables relacionadas con Heroku"
end

puts ""
puts "DATABASE_URL actual:"
if ENV['DATABASE_URL']
  masked_db = ENV['DATABASE_URL'].gsub(/:[^:@]+@/, ':****@')
  puts "  #{masked_db}"
  
  if ENV['DATABASE_URL'].include?('dpg-')
    puts ""
    puts "  ⚠ Esta es la URL de Render (dpg- indica Render Postgres)"
    puts "  Necesitas la URL de Heroku para exportar desde ahí"
  end
else
  puts "  No configurada"
end

puts ""
puts "Todas las variables de entorno que contienen 'postgres' o 'database':"
db_vars = ENV.to_h.select { |k, v| k.to_s.downcase.include?('postgres') || k.to_s.downcase.include?('database') }
db_vars.each do |key, value|
  masked_value = value.gsub(/:[^:@]+@/, ':****@')
  puts "  #{key}: #{masked_value}"
end

puts ""
puts "=" * 60
