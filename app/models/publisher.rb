class Publisher < ApplicationRecord

  # Relationships
  has_many :books

  # Validations
  validates :name, presence: true                  

  # Scopes
  scope :alphabetical, -> { order('name') }

end
