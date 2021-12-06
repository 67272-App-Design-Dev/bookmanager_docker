json.extract! book, :id, :title, :publisher_id, :proposal_date, :contract_date, :published_date, :units_sold, :created_at, :updated_at
json.url book_url(book, format: :json)
