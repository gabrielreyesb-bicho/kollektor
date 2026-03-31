module ApplicationHelper
  def mosaic_view?
    controller_name == 'music' && 
    ['genres_mosaic', 'authors_mosaic', 'albums_mosaic'].include?(action_name)
  end
end
