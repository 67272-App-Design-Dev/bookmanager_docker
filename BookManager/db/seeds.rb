# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
authors = Author.create([{first_name: "George", last_name: "R. R. Martin"}, 
                         {first_name: "C.S.", last_name: "Lewis"}, 
                         {first_name: "Terry", last_name: "Pratchett"}, 
                         {first_name: "Stephen", last_name: "King"},
                         {first_name: "Peter", last_name: "Straub"},
                         {first_name: "Neil", last_name: "Gaiman"}])
puts "Created authors"
puts authors
publishers = Publisher.create([{name: "Bantam Spectra"}, 
                               {name: "HarperCollins"},
                               {name: "Viking"},
                               {name: "Workman"}])
puts "Created publishers"
puts publishers
books = Book.create([{title: "The Talisman", publisher: publishers[2], proposal_date: Date.new(1984,4,10), contract_date:Date.new(1984,5,10), published_date: Date.new(1984,11,8), units_sold: 25000}, 
                     {title: "Game of Thrones", publisher: publishers[0], proposal_date: Date.new(1996,3,1), contract_date:Date.new(1996,5,1), published_date: Date.new(1996,8,1), units_sold: 20000},
                     {title: "Chronicles of Narnia", publisher: publishers[1], proposal_date: Date.new(1950,3,10), contract_date:Date.new(1950,4,10), published_date: Date.new(1950,5,10), units_sold: 15000},
                     {title: "Good Omens", publisher: publishers[3], proposal_date: Date.new(1990,3,10), contract_date: Date.new(1990,4,10), published_date: Date.new(1990,5,10), units_sold: 5000}])
puts "Created books"
puts books
bookAuthors = BookAuthor.create([{author: authors[0], book: books[2]},
                                 {author: authors[1], book: books[3]}, 
                                 {author: authors[2], book: books[1]}, {author: authors[5], book: books[1]},
                                 {author: authors[3], book: books[0]}, {author: authors[4], book: books[0]}])
puts "Created book authors"
puts bookAuthors
