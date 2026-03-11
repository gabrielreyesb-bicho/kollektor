#!/usr/bin/env ruby

# Script inteligente que intenta exportar desde Heroku o Render
# Ejecutar: rails runner scripts/export_from_render_or_heroku.rb

require 'json'
require 'fileutils'

puts "=" * 60
puts "EXPORTADOR INTELIGENTE DE DATOS"
puts "=" * 60
puts ""

# Verificar DATABASE_URL actual
current_db_url = ENV['DATABASE_URL']
if current_db_url
  masked_url = current_db_url.gsub(/:[^:@]+@/, ':****@')
  puts "DATABASE_URL actual: #{masked_url}"
  
  if current_db_url.include?('dpg-')
    puts "  → Esta es una base de datos de Render"
  elsif current_db_url.include?('amazonaws') || current_db_url.include?('ec2-')
    puts "  → Esta parece ser una base de datos de Heroku/AWS"
  end
  puts ""
end

# Buscar variables de entorno que puedan tener la URL de Heroku
puts "Buscando variables de entorno relacionadas con Heroku..."
heroku_vars = ENV.to_h.select do |k, v|
  v.to_s.downcase.include?('heroku') || 
  v.to_s.include?('amazonaws') ||
  v.to_s.include?('ec2-') ||
  (k.to_s.downcase.include?('heroku') && v.to_s.start_with?('postgres'))
end

if heroku_vars.any?
  puts "✓ Encontradas variables que pueden contener URL de Heroku:"
  heroku_vars.each do |key, value|
    if value.to_s.start_with?('postgres')
      masked = value.gsub(/:[^:@]+@/, ':****@')
      puts "  #{key}: #{masked}"
    end
  end
  puts ""
end

# Verificar conexión actual
puts "Verificando conexión a la base de datos actual..."
begin
  ActiveRecord::Base.connection.execute("SELECT 1")
  puts "✓ Conexión exitosa"
  
  # Contar registros
  puts ""
  puts "Datos disponibles en la base de datos actual:"
  models = {
    'Users' => User,
    'Albums' => Album,
    'Authors' => Author,
    'Genres' => Genre,
    'Countries' => Country,
    'Series' => Series,
    'Actors' => Actor,
    'Notifications' => Notification
  }
  
  models.each do |name, model|
    begin
      count = model.count
      puts "  #{name}: #{count} registros"
    rescue => e
      puts "  #{name}: Error (#{e.message})"
    end
  end
  
  puts ""
  puts "¿Quieres exportar estos datos? (S/n)"
  puts "Si esta es la base de datos de Render y ya tiene los datos migrados,"
  puts "puedes exportar desde aquí. Si no, necesitamos acceso a Heroku."
  
rescue => e
  puts "✗ Error de conexión: #{e.message}"
  exit 1
end

# Proceder con la exportación
export_dir = Rails.root.join('tmp', 'data_export')
FileUtils.mkdir_p(export_dir)

puts ""
puts "Exportando datos a: #{export_dir}"
puts ""

models.each do |name, model|
  begin
    records = model.all
    puts "Exportando #{name}... (#{records.count} registros)"
    
    data = records.map do |record|
      attrs = record.attributes.except(
        'password_digest',
        'encrypted_password',
        'reset_password_token',
        'reset_password_sent_at',
        'unlock_token'
      )
      
      attrs.each do |key, value|
        if value.is_a?(Time) || value.is_a?(Date) || value.is_a?(DateTime)
          attrs[key] = value.iso8601
        end
      end
      
      attrs
    end
    
    file_path = export_dir.join("#{name.downcase}.json")
    File.write(file_path, JSON.pretty_generate(data))
    puts "  ✓ Guardado: #{file_path}"
  rescue => e
    puts "  ✗ Error: #{e.message}"
  end
end

# Exportar Active Storage
puts ""
puts "Exportando Active Storage..."
begin
  attachments = ActiveStorage::Attachment.all.map do |a|
    {
      id: a.id,
      name: a.name,
      record_type: a.record_type,
      record_id: a.record_id,
      blob_id: a.blob_id,
      created_at: a.created_at.iso8601
    }
  end
  
  blobs = ActiveStorage::Blob.all.map do |b|
    {
      id: b.id,
      key: b.key,
      filename: b.filename.to_s,
      content_type: b.content_type,
      byte_size: b.byte_size,
      checksum: b.checksum,
      created_at: b.created_at.iso8601,
      service_name: b.service_name
    }
  end
  
  File.write(export_dir.join('active_storage_attachments.json'), JSON.pretty_generate(attachments))
  File.write(export_dir.join('active_storage_blobs.json'), JSON.pretty_generate(blobs))
  
  puts "  ✓ Exportados #{attachments.count} attachments y #{blobs.count} blobs"
rescue => e
  puts "  ✗ Error: #{e.message}"
end

puts ""
puts "=" * 60
puts "EXPORTACIÓN COMPLETADA"
puts "=" * 60
puts "Archivos en: #{export_dir}"
puts ""
puts "Si estos NO son todos tus datos de Heroku, necesitas:"
puts "1. Encontrar la DATABASE_URL de Heroku"
puts "2. O contactar a soporte de Heroku para recuperar acceso"
