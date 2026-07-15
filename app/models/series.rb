class Series < ApplicationRecord
  belongs_to :genre
  belongs_to :user
  
  has_one_attached :cover_image

  validates :name, presence: true
  validates :year, presence: true, numericality: { greater_than: 1900, less_than_or_equal_to: Date.current.year + 1 }

  has_many :notifications, dependent: :destroy

  def imdb_search_url
    if imdb_id.present?
      "https://www.imdb.com/title/#{imdb_id}/"
    else
      query = [name, year].compact.join(' ')
      "https://www.imdb.com/find?q=#{URI.encode_www_form_component(query)}"
    end
  end
end 