class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  # Relationships
  has_many :albums, dependent: :destroy
  has_many :authors, dependent: :destroy
  has_many :genres, dependent: :destroy
  has_many :series, dependent: :destroy
  has_many :notifications, dependent: :destroy
end
