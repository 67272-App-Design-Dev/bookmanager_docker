require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  
  def test_author_creation
  	author = Author.create(first_name: "John")
  	assert_equal author.name, "Smith, John"
  end
end
