class Album < ApplicationRecord
  belongs_to :genre
  belongs_to :author
  belongs_to :user
  has_one_attached :cover_image

  validates :name, presence: true, 
                  uniqueness: { 
                    scope: :author_id,
                    case_sensitive: false,
                    message: "already exists for this author" 
                  }
  validates :year, presence: true, 
            numericality: { only_integer: true, 
                          greater_than: 1900, 
                          less_than_or_equal_to: Time.current.year }
  validates :genre, presence: true
  validates :author, presence: true
  validate :acceptable_cover_image, if: :cover_image_attached?

  scope :search, ->(query) {
    joins(:author, :genre)
      .where("LOWER(albums.name) LIKE :query OR 
              LOWER(authors.name) LIKE :query OR 
              LOWER(genres.name) LIKE :query", 
              query: "%#{query.downcase}%")
  }

  # Orden para sugerencias tipo "ruleta": prioriza los álbumes con menos
  # "likes" (los que aún no has escuchado/marcado) y, a igualdad de likes,
  # en orden aleatorio uniforme — sin sesgo por autor ni género. Así favorece
  # lo no escuchado y no repite siempre los mismos.
  scope :suggestions_order, -> {
    random_fn = connection.adapter_name.downcase.include?('mysql') ? 'RAND()' : 'RANDOM()'
    order(:likes_count).order(Arel.sql(random_fn))
  }

  # Álbumes que aún pueden salir en "Get Lucky". Un álbum descartado sigue en
  # la colección (aparece en Albums, Music y estadísticas), solo deja de
  # sugerirse.
  scope :suggestable, -> { where(dismissed_at: nil) }

  # Fuente única de las sugerencias aleatorias. La usan Get Lucky y el mood
  # prompt diario; antes cada uno tenía su propia copia y era fácil que se
  # separaran (p. ej. que uno respetara los descartes y el otro no).
  scope :random_suggestions, ->(count = 4) {
    suggestable.includes(:author, :genre).with_attached_cover_image
               .suggestions_order.limit(count)
  }

  def dismissed?
    dismissed_at.present?
  end

  def dismiss!
    update!(dismissed_at: Time.current)
  end

  def restore!
    update!(dismissed_at: nil)
  end

  def increment_likes
    self.class.increment_counter(:likes_count, id)
    reload
  end

  def youtube_music_url
    "https://music.youtube.com/search?q=#{URI.encode_www_form_component("#{name} #{author.name} album")}"
  end


  private
    def cover_image_attached?
      cover_image.attached?
    end

    def acceptable_cover_image
      return unless cover_image.attached?
      
      if cover_image.byte_size > 5.megabytes
        errors.add(:cover_image, "must be less than 5MB")
      end
      
      acceptable_types = ["image/jpeg", "image/png", "image/jpg"]
      unless acceptable_types.include?(cover_image.content_type)
        errors.add(:cover_image, "must be a JPEG or PNG")
      end
    end
end 