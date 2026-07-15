#!/usr/bin/env ruby

# Script Ruby para exportar datos de Heroku usando Rails
# Uso: rails runner scripts/export_heroku_data.rb

require 'json'
require 'fileutils'

export_dir = Rails.root.join('tmp', 'heroku_export')
FileUtils.mkdir_p(export_dir)

puts "=" * 60
puts "EXPORTANDO DATOS DE HEROKU"
puts "=" * 60
puts "Directorio de exportación: #{export_dir}"
puts ""

# Verificar conexión
begin
  ActiveRecord::Base.connection.execute("SELECT 1")
  db_url = ENV['DATABASE_URL']
  if db_url
    masked_url = db_url.gsub(/:[^:@]+@/, ':****@')
    puts "✓ Conexión exitosa"
    puts "  DATABASE_URL: #{masked_url}"
  else
    puts "✓ Conexión exitosa (DATABASE_URL no configurada)"
  end
  puts ""
rescue => e
  puts "✗ Error conectando: #{e.message}"
  puts ""
  puts "Configura DATABASE_URL con la URL de Heroku:"
  puts "  export DATABASE_URL='postgres://user:pass@host:port/dbname'"
  puts "  rails runner scripts/export_heroku_data.rb"
  exit 1
end

# Modelos a exportar
models = [
  'User',
  'Album', 
  'Author',
  'Genre',
  'Country',
  'Series',
  'Notification'
]

models.each do |model_name|
  begin
    model_class = model_name.constantize
    records = model_class.all
    
    puts "Exportando #{model_name}... (#{records.count} registros)"
    
    data = records.map do |record|
      # Excluir campos sensibles
      attrs = record.attributes.except(
        'password_digest',
        'encrypted_password', 
        'reset_password_token',
        'reset_password_sent_at',
        'unlock_token'
      )
      
      # Convertir fechas a strings para JSON
      attrs.each do |key, value|
        if value.is_a?(Time) || value.is_a?(Date) || value.is_a?(DateTime)
          attrs[key] = value.iso8601
        end
      end
      
      attrs
    end
    
    file_path = export_dir.join("#{model_name.underscore.pluralize}.json")
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
puts "Para importar a Render:"
puts "  rails import_data:from_json"
