namespace :export_data do
  desc 'Export all data from Heroku database to JSON files'
  task heroku_export: :environment do
    require 'json'
    require 'fileutils'
    
    export_dir = Rails.root.join('tmp', 'heroku_export')
    FileUtils.mkdir_p(export_dir)
    
    puts "=" * 60
    puts "EXPORTANDO DATOS DE HEROKU"
    puts "=" * 60
    puts "Directorio de exportación: #{export_dir}"
    puts ""
    
    # Verificar conexión a la base de datos
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      puts "✓ Conexión a la base de datos exitosa"
      puts "  DATABASE_URL: #{ENV['DATABASE_URL']&.gsub(/:[^:@]+@/, ':****@') || 'No configurada'}"
      puts ""
    rescue => e
      puts "✗ Error conectando a la base de datos: #{e.message}"
      puts ""
      puts "Asegúrate de tener DATABASE_URL configurada apuntando a Heroku"
      exit 1
    end
    
    # Exportar cada modelo
    models_to_export = [
      'User',
      'Album',
      'Author',
      'Genre',
      'Country',
      'Series',
      'Actor',
      'Notification'
    ]
    
    models_to_export.each do |model_name|
      begin
        model_class = model_name.constantize
        records = model_class.all
        
        puts "Exportando #{model_name}... (#{records.count} registros)"
        
        data = records.map do |record|
          record.attributes.except('password_digest', 'encrypted_password', 'reset_password_token')
        end
        
        file_path = export_dir.join("#{model_name.underscore.pluralize}.json")
        File.write(file_path, JSON.pretty_generate(data))
        
        puts "  ✓ Guardado en: #{file_path}"
      rescue => e
        puts "  ✗ Error exportando #{model_name}: #{e.message}"
      end
    end
    
    # Exportar Active Storage attachments
    puts ""
    puts "Exportando Active Storage attachments..."
    begin
      attachments_data = []
      
      ActiveStorage::Attachment.all.each do |attachment|
        attachments_data << {
          id: attachment.id,
          name: attachment.name,
          record_type: attachment.record_type,
          record_id: attachment.record_id,
          blob_id: attachment.blob_id,
          created_at: attachment.created_at
        }
      end
      
      blobs_data = []
      ActiveStorage::Blob.all.each do |blob|
        blobs_data << {
          id: blob.id,
          key: blob.key,
          filename: blob.filename.to_s,
          content_type: blob.content_type,
          byte_size: blob.byte_size,
          checksum: blob.checksum,
          created_at: blob.created_at,
          service_name: blob.service_name
        }
      end
      
      File.write(export_dir.join('active_storage_attachments.json'), JSON.pretty_generate(attachments_data))
      File.write(export_dir.join('active_storage_blobs.json'), JSON.pretty_generate(blobs_data))
      
      puts "  ✓ Exportados #{attachments_data.count} attachments y #{blobs_data.count} blobs"
    rescue => e
      puts "  ✗ Error exportando Active Storage: #{e.message}"
    end
    
    puts ""
    puts "=" * 60
    puts "EXPORTACIÓN COMPLETADA"
    puts "=" * 60
    puts "Todos los archivos están en: #{export_dir}"
    puts ""
    puts "Para importar estos datos a Render, usa:"
    puts "  rails import_data:from_json"
  end
  
  desc 'Export database as PostgreSQL dump (requires pg_dump)'
  task pg_dump: :environment do
    require 'uri'
    
    database_url = ENV['DATABASE_URL']
    
    if database_url.nil? || database_url.empty?
      puts "✗ DATABASE_URL no está configurada"
      puts ""
      puts "Configúrala con:"
      puts "  export DATABASE_URL='postgres://user:pass@host:port/dbname'"
      exit 1
    end
    
    begin
      uri = URI.parse(database_url)
      
      dump_file = Rails.root.join('tmp', "heroku_dump_#{Time.now.strftime('%Y%m%d_%H%M%S')}.sql")
      FileUtils.mkdir_p(File.dirname(dump_file))
      
      puts "=" * 60
      puts "CREANDO DUMP DE POSTGRESQL"
      puts "=" * 60
      puts "Base de datos: #{uri.host}:#{uri.port}/#{uri.path[1..-1]}"
      puts "Archivo de salida: #{dump_file}"
      puts ""
      
      # Construir comando pg_dump
      cmd = [
        'pg_dump',
        "--host=#{uri.host}",
        "--port=#{uri.port || 5432}",
        "--username=#{uri.user}",
        "--dbname=#{uri.path[1..-1]}",
        '--no-password',
        '--verbose',
        '--clean',
        '--if-exists',
        '--format=custom',
        "--file=#{dump_file}"
      ]
      
      # Configurar PGPASSWORD
      ENV['PGPASSWORD'] = uri.password if uri.password
      
      puts "Ejecutando pg_dump..."
      system(*cmd)
      
      if $?.success?
        puts ""
        puts "=" * 60
        puts "DUMP COMPLETADO EXITOSAMENTE"
        puts "=" * 60
        puts "Archivo: #{dump_file}"
        puts "Tamaño: #{File.size(dump_file) / 1024 / 1024} MB"
        puts ""
        puts "Para restaurar en Render:"
        puts "  pg_restore -d <DATABASE_URL_RENDER> #{dump_file}"
      else
        puts ""
        puts "✗ Error creando el dump. Verifica:"
        puts "  1. Que tengas pg_dump instalado"
        puts "  2. Que la DATABASE_URL sea correcta"
        puts "  3. Que tengas acceso a la base de datos"
        exit 1
      end
    rescue => e
      puts "✗ Error: #{e.message}"
      exit 1
    end
  end
end
