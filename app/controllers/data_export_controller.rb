class DataExportController < ApplicationController
  # Permitir acceso sin autenticación solo para este controlador
  skip_before_action :authenticate_user!, only: [:export_all, :check_data]
  
  # Protección básica con token (configura EXPORT_TOKEN en Render)
  before_action :verify_export_token, only: [:export_all]
  
  def check_data
    # Endpoint para verificar qué datos hay sin exportar
    data_summary = {
      users: User.count,
      albums: Album.count,
      authors: Author.count,
      genres: Genre.count,
      countries: Country.count,
      series: Series.count,
      notifications: Notification.count,
      active_storage_attachments: ActiveStorage::Attachment.count,
      active_storage_blobs: ActiveStorage::Blob.count,
      database_url: ENV['DATABASE_URL']&.gsub(/:[^:@]+@/, ':****@') || 'No configurada',
      is_render_db: ENV['DATABASE_URL']&.include?('dpg-') || false,
      is_heroku_db: ENV['DATABASE_URL']&.include?('amazonaws') || ENV['DATABASE_URL']&.include?('ec2-') || false
    }
    
    # Buscar variables de entorno que puedan tener la URL de Heroku
    heroku_vars = ENV.to_h.select do |k, v|
      v.to_s.downcase.include?('heroku') || 
      v.to_s.include?('amazonaws') ||
      v.to_s.include?('ec2-') ||
      (k.to_s.downcase.include?('heroku') && v.to_s.start_with?('postgres'))
    end
    
    if heroku_vars.any?
      data_summary[:possible_heroku_vars] = heroku_vars.map do |key, value|
        {
          key: key,
          value: value.to_s.start_with?('postgres') ? value.gsub(/:[^:@]+@/, ':****@') : value
        }
      end
    end
    
    render json: data_summary
  end
  
  def export_all
    require 'json'
    
    export_data = {
      exported_at: Time.current.iso8601,
      database_info: {
        url: ENV['DATABASE_URL']&.gsub(/:[^:@]+@/, ':****@') || 'No configurada',
        adapter: ActiveRecord::Base.connection.adapter_name
      },
      data: {}
    }
    
    # Exportar cada modelo
    models = {
      'users' => User,
      'albums' => Album,
      'authors' => Author,
      'genres' => Genre,
      'countries' => Country,
      'series' => Series,
      'notifications' => Notification
    }
    
    models.each do |key, model_class|
      begin
        records = model_class.all.map do |record|
          attrs = record.attributes.except(
            'password_digest',
            'encrypted_password',
            'reset_password_token',
            'reset_password_sent_at',
            'unlock_token'
          )
          
          # Convertir fechas a strings
          attrs.each do |k, v|
            if v.is_a?(Time) || v.is_a?(Date) || v.is_a?(DateTime)
              attrs[k] = v.iso8601
            end
          end
          
          attrs
        end
        
        export_data[:data][key] = {
          count: records.count,
          records: records
        }
      rescue => e
        export_data[:data][key] = {
          error: e.message
        }
      end
    end
    
    # Exportar Active Storage metadata
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
      
      export_data[:data]['active_storage_attachments'] = {
        count: attachments.count,
        records: attachments
      }
      
      export_data[:data]['active_storage_blobs'] = {
        count: blobs.count,
        records: blobs
      }
    rescue => e
      export_data[:data]['active_storage'] = {
        error: e.message
      }
    end
    
    # Enviar como JSON descargable
    send_data JSON.pretty_generate(export_data),
              filename: "kollektor_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json",
              type: 'application/json',
              disposition: 'attachment'
  end
  
  private
  
  def verify_export_token
    expected_token = ENV['EXPORT_TOKEN'] || 'change_this_token_in_production'
    provided_token = params[:token] || request.headers['X-Export-Token']
    
    unless provided_token == expected_token
      render json: { error: 'Token inválido' }, status: :unauthorized
    end
  end
end
