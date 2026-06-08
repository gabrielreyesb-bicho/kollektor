class Genre < ApplicationRecord
  belongs_to :user
  belongs_to :collection_type
  has_one_attached :image

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :user_id }
  validate :acceptable_image, if: :image_attached?
  has_many :authors, dependent: :destroy
  has_many :albums, dependent: :destroy
  has_many :series, dependent: :destroy

  scope :search, ->(query) {
    where("LOWER(genres.name) LIKE :query OR
           LOWER(genres.description) LIKE :query",
           query: "%#{query.downcase}%")
  }

  scope :by_collection_type, ->(collection_type_name) {
    joins(:collection_type).where(collection_types: { name: collection_type_name })
  }

  # Fallback scope when collection_type doesn't exist
  scope :with_collection_type, -> {
    joins(:collection_type)
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
