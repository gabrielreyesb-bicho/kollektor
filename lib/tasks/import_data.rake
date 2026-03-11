namespace :import_data do
  desc 'Import data from JSON files exported from Heroku'
  task from_json: :environment do
    require 'json'
    
    export_dir = Rails.root.join('tmp', 'heroku_export')
    
    unless Dir.exist?(export_dir)
      puts "✗ No se encontró el directorio de exportación: #{export_dir}"
      puts ""
      puts "Primero ejecuta: rails export_data:heroku_export"
      exit 1
    end
    
    puts "=" * 60
    puts "IMPORTANDO DATOS DESDE JSON"
    puts "=" * 60
    puts "Directorio: #{export_dir}"
    puts ""
    
    # Importar en orden para respetar dependencias
    import_order = [
      ['countries.json', 'Country'],
      ['genres.json', 'Genre'],
      ['authors.json', 'Author'],
      ['users.json', 'User'],
      ['albums.json', 'Album'],
      ['actors.json', 'Actor'],
      ['series.json', 'Series'],
      ['notifications.json', 'Notification']
    ]
    
    import_order.each do |file_name, model_name|
      file_path = export_dir.join(file_name)
      
      unless File.exist?(file_path)
        puts "⚠ Saltando #{file_name} (archivo no encontrado)"
        next
      end
      
      begin
        data = JSON.parse(File.read(file_path))
        model_class = model_name.constantize
        
        puts "Importando #{model_name}... (#{data.count} registros)"
        
        imported = 0
        skipped = 0
        
        data.each do |record_data|
          # Buscar si ya existe
          existing = if model_class.column_names.include?('id')
            model_class.find_by(id: record_data['id'])
          else
            nil
          end
          
          if existing
            skipped += 1
          else
            # Remover id para que Rails asigne uno nuevo, o mantenerlo si quieres preservar IDs
            record_data_without_id = record_data.except('id')
            model_class.create!(record_data_without_id)
            imported += 1
          end
        end
        
        puts "  ✓ Importados: #{imported}, Saltados (ya existían): #{skipped}"
      rescue => e
        puts "  ✗ Error importando #{model_name}: #{e.message}"
        puts "    #{e.backtrace.first}"
      end
    end
    
    # Importar Active Storage
    puts ""
    puts "Importando Active Storage..."
    begin
      attachments_file = export_dir.join('active_storage_attachments.json')
      blobs_file = export_dir.join('active_storage_blobs.json')
      
      if File.exist?(attachments_file) && File.exist?(blobs_file)
        blobs_data = JSON.parse(File.read(blobs_file))
        attachments_data = JSON.parse(File.read(attachments_file))
        
        # Nota: Los blobs y attachments de Active Storage son más complejos
        # porque los archivos físicos están en S3. Esto solo importa los metadatos.
        puts "  ⚠ Active Storage: Solo se importarán metadatos."
        puts "     Los archivos físicos deben estar en S3 con las mismas keys."
      end
    rescue => e
      puts "  ✗ Error importando Active Storage: #{e.message}"
    end
    
    puts ""
    puts "=" * 60
    puts "IMPORTACIÓN COMPLETADA"
    puts "=" * 60
  end
end
