class Album < ApplicationRecord
  belongs_to :genre
  belongs_to :author
  belongs_to :user, optional: true
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

  # Returns albums ordered by likes count, strongly favoring those with fewer likes
  # The formula gives much higher weight to albums with zero likes
  scope :weighted_by_likes, -> {
    # Order by likes_count first (primary), then by random (secondary)
    # This ensures albums with 0 likes always come before those with more likes,
    # and within each likes_count group, the order is random
    # Use database-specific random function for better compatibility
    if connection.adapter_name.downcase.include?('sqlite')
      order(:likes_count).order('RANDOM()')
    elsif connection.adapter_name.downcase.include?('postgresql')
      order(:likes_count).order('RANDOM()')
    elsif connection.adapter_name.downcase.include?('mysql')
      order(:likes_count).order('RAND()')
    else
      # Fallback for other databases
      order(:likes_count)
    end
  }

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