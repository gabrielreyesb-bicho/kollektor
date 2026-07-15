class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_notifications, if: -> { user_signed_in? && ['series', 'series_collection'].include?(controller_name) }
  # before_action :set_sidebar_data, unless: :devise_controller?

  def after_sign_in_path_for(resource)
    music_path
  end

  private

  def set_sidebar_data
    # ... existing code ...
  end

  def set_notifications
    @notifications = current_user.notifications.order(created_at: :desc).limit(10)
    @unread_notifications_count = current_user.notifications.where(read: false).count
  end
end
