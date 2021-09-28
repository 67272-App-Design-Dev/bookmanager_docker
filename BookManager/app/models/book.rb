class Book < ApplicationRecord

  # Relationships
  belongs_to :publisher                     
  has_many :book_authors
  has_many :authors, through: :book_authors

  # Validations
  validates :title, presence: true
  validates :units_sold, numericality: { only_integer: true }

  # Date validations using validates_timeliness gem
  # see https://github.com/adzap/validates_timeliness for documentation 
  validates_date :proposal_date, on_or_before: -> { Date.current }
  validates_date :contract_date, after: :proposal_date, on_or_before: -> { Date.current }, allow_blank: true
  validates_date :published_date, after: :contract_date, on_or_before: -> { Date.current }, allow_blank: true
                      
  # Scopes
  scope :alphabetical, -> { order('title') }

end