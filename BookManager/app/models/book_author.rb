class BookAuthor < ApplicationRecord
  
  # Relationships
  belongs_to :book
  belongs_to :author

end
