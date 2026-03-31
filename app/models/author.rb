class Author < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :country
  belongs_to :genre
  has_one_attached :image
  has_many :albums, dependent: :destroy
  
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :user_id }
  validates :genre_id, presence: true
  validates :country_id, presence: true
  validate :acceptable_image, if: :image_attached?
  
  scope :search, ->(query) {
    where("LOWER(authors.name) LIKE :query OR LOWER(authors.description) LIKE :query", query: "%#{query.downcase}%")
  }
  
  scope :by_collection_type, ->(collection_type_name) {
    joins(genre: :collection_type).where(collection_types: { name: collection_type_name })
  }
  
  # Fallback scope when collection_type doesn't exist
  scope :with_genre, -> {
    joins(:genre)
  }
  
  private
    def image_attached?
      image.attached?
    end
    
    def acceptable_image
      return unless image.attached?
      
      if image.byte_size > 5.megabytes
        errors.add(:image, "must be less than 5MB")
      end
      
      acceptable_types = ["image/jpeg", "image/png", "image/jpg"]
      unless acceptable_types.include?(image.content_type)
        errors.add(:image, "must be a JPEG or PNG")
      end
    end
end 