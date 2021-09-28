# Book Manager ByeBug Teaching Session

There is a rails 5 application [BookManager - ByeBug]. It has some code that I added that breaks the application. Run bundle install and rails db:migrate to set it up first. You will work through with the class and figure out how to fix the application. The following are the bugs:

## Books won’t display properly

1.  You will first go to this page and ask the class what they think is wrong. (Note the undefined method `title' for nil:NilClass) Ask the class where they think you should start debugging

2.  The right place is to look at the index action of BooksController. This is because we are currently looking at the route that maps to that action. Put byebug in the first line of the index action and refresh the page.

3.  Basically run through step by step to see what is wrong. Ask the class at each step what to do next in order to figure out the bug. Once you hit the line that sets @top_seller to the first index of sort_by_units_sold, then ask the class why they think this will break the front end.

4.  The answer is that when there are no books in the database, the top seller will be nil. The correct solution should be to add a check in the index view of whether or not @top_seller is nil before getting its title.

5.  Verify that it works! You can create a new publisher and then book to show that it works, but not necessary.

## Last Name can't be blank error

1.  Ask the class what they think is wrong? Where in the application do you think the problem is, Model, Controller, or View? The correct answer should be controller, since the model is validating properly.

2.  Now ask them where they should put byebug? It should be placed in the create action of AuthorsController.

3.  Now step through line by line and ask the class what they think is wrong?

Some things to go over
- Check that @author.valid? Is false
- Check that @author.save is false too
- Check the @author object and see that last_name is missing

4.  Ask them why they think it is missing, then check what author_params returns.

5.  Show that last_name was unpermitted and look into that function. The right solution is that when we whitelisted the params in the function author_params, we misspelled last_name as lst_name.


# Book Manager Lab (Updated 2017)

## Part 1

1.  Create a new Rails application called "BookManager", switch directories (`cd`) into this Rails app from the command line.

Create a git repository, add and commit the initial files with the commit message "Initial commit".

2.  Create three models and the scaffolding from the command line using the command:

        rails generate scaffold <Model> <attribute>:<data type>

    Below are the details of each model:

    ### Book

    *   title (string)
    *   publisher_id (integer)
    *   proposal_date (date)
    *   contract_date (date)
    *   published_date (date)
    *   units_sold (integer)

    ### Publisher

    *   name (string)

    ### Author

    *   first_name (string)
    *   last_name (string)
3.  Create an additional model called `BookAuthor` using the `rails generate model` command. The attributes of this model are `book_id (integer)` and `author_id (integer)`.

    We don't need a full set of views or a controller, just an associative entity to connect books and authors, so using a model generator is sufficient in this case.

    After creating these models, migrate the database and save all this generated code to git.

4.  Create and switch to a new branch in git called models. Open the `Book` model in your editor and add the following three relationships to that model:
    ```ruby
    belongs_to :publisher                     
    has_many :book_authors
    has_many :authors, through: :book_authors 
    ```

    In addition, add the following validations:

    ```ruby
    validates_presence_of :title                        
    validates_numericality_of :units_sold 
    ```

    For the `units_sold`, refer to the Rails API at [apidock.com](http://apidock.com/rails) for the option that restricts the values to integers only.

    Finally, add the following scope:

    ```ruby
    scope :alphabetical, -> { order('title') }
    ```

5.  Go to the Publisher model and add the following relationship:
    ```ruby
    has_many :books 
    ```

6.  Go to the Author model and add the following relationships:

    ```ruby
    has_many :book_authors
    has_many :books, through: :book_authors  
    ```

    In addition, add the following validations, scopes and methods:

    ```ruby
    validates_presence_of :first_name, :last_name 
    scope :alphabetical, -> { order('last_name, first_name') }

    def name
      "#{last_name}, #{first_name}"
    end
    ```

7.  Go to the BookAuthor model and add the following relationships:
    ```ruby
    belongs_to :book
    belongs_to :author
    ```

    Once the model code is complete, restart the server and be sure it is all running and that there are no typos (common error) in your code by looking at the index pages of books, authors and publishers. 

    ### Indexes

    * http://localhost:3000/books
    * http://localhost:3000/publishers
    * http://localhost:3000/authors

    If it’s all good, commit these changes to your git repo and then merge these changes into the master branch. Reminder, that should look like `git checkout master` to get back to the master branch and `git merge models` to incorporate your most recent updates.

8) 
    *   Before we dive into views, we are going to complete some of the missing validations in the Book model. Create and move to a new book branch with `git checkout -b book`.

    *  Since Rails does not have built-in date validations, we are using the [validates_timeliness gem](https://github.com/adzap/validates_timeliness); find the documentation for this gem by clicking on the link and scroll down the webpage to see some example uses. 

    * First, we need to include the gem in our project. We do this by going to the Gemfile and adding in `'gem 'validates_timeliness'`. Now run `bundle update` to make sure you have the gem on your machine. Lastly, it is necessary to also run the `rails generate validates_timeliness:install` command to have a couple of files generated for the project, so do so now to make sure that you have them.

9) Now that we have the `validates_timeliness` gem installed, add the following validations to the following fields in the Book model.

    ##### Proposal Date
    *   Add a validation so that the `proposal_date` is a legitimate date and that it is either the current date or some time in the past. (The reason is you shouldn't be allowed to record a proposal you haven't yet received.)

    ##### Contract Date
    *   Add a validation to `contract_date` to ensure that it is a legitimate date and that it is either the current date or some time in the past. (The reason is you shouldn't be allowed to record a contract you haven't yet signed.)

    *   Also make sure that the `contract_date` is some time after the `proposal_date` as you can't sign contracts for books yet to be proposed.

    *   Finally allow the `contract_date` to be blank as not all books we are tracking have contracts yet.

    ##### Published Date
    *   Add a validation to `published_date` so that it is also a legitimate date and that it is either the current date or some time in the past.

    *   Also make sure that the `published_date` is some time after the `contract_date` as you can't publish books without contracts.

    *   Finally allow the `published_date` to be blank as not all books we are tracking are published yet.

    Start (or restart) your rails server and verify that these validations work in the interface. Confirm this with a TA before continuing. **Do not merge back into `master`**. **2017 Update for Vagrant users**: `rails server` breaks on old labs. Until a better solution is found, open your `Gemfile` and remove `gem 'thin'`. Then run `rails server -b localhost`.

* * *

# <span class="mega-icon mega-icon-issue-opened"></span>Stop

Show a TA that you have the basic Rails app set up and working, and that you have properly saved the code to git. Make sure the TA initials your sheet.

* * *

## Part 2

1.  Now go to the web interface and add a new publisher: "Pragmatic Bookshelf". After that, go to the books section and add a new book: "Agile Web Development with Rails" which was published by Pragmatic Bookshelf in 2013\. Make sure to update the three date fields with dates that follow the validations for `proposal_date`, `contract_date`, and `published_date` from Part 1! **Note that you need to refer to the publisher by its id (1), rather than its name in the current interface**. Thinking about this, and some other problems with the current interface, we will begin to make the interface more usable, working now in a new branch called 'interface'

2.  We'll begin by adding some more publishers directly into the database using the command line. If we think back to the SimpleQuotes lab last week, the easiest way to insert new data is by opening a new command line tab in the same directory and running `rails db`. Then paste the publishers_sql and authors_sql code given so that we have multiple publishers and authors to choose from (and sharpen our db skills slightly). **Note**: do not add the first publisher since we have already added Pragmatic Bookshelf via the web interface; if you do you will get an error because they are already in the db with a id=1.

    ```sql
    -- SQL for authors
    INSERT INTO "authors" VALUES (1, 'Sam', 'Ruby', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "authors" VALUES (2, 'Dave', 'Thomas', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "authors" VALUES (3, 'Hal', 'Fulton', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "authors" VALUES (4, 'Robert', 'Hoekman', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "authors" VALUES (5, 'David', 'Hannson', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "authors" VALUES (6, 'Dante', 'Alighieri', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "authors" VALUES (7, 'William', 'Shakespeare', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "authors" VALUES (8, 'Jane', 'Austen', '2015-02-09 12:00:00', '2014-02-10 12:00:00');

    -- SQL for publishers
    INSERT INTO "publishers" VALUES (1, 'Pragmatic Bookshelf', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "publishers" VALUES (2, 'Washington Square Press', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "publishers" VALUES (3, 'Addison Wesley', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "publishers" VALUES (4, 'Everyman Library', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    INSERT INTO "publishers" VALUES (5, 'New Riders', '2015-02-09 12:00:00', '2014-02-10 12:00:00');
    ```

3.  The first thing we will do is switch the 'publisher_id' field (a text box where you are supposed to remember and type out the appropriate publisher's id) to a drop-down list. Now that we have some publishers in the system, go to the `_form` partial in the Books view and change the publisher_id text_field to the following line:

    ```erb
    <%= form.collection_select :publisher_id, Publisher.alphabetical, :id, :name %>
    ```

    Look at the new form on the web page. It's an improvement (I also like to convert the number_field for year_published to a straight text field, but not required), but it'd be a little nicer if it didn't default to the first publisher. Go to [apidock.com/rails](http://apidock.com/rails) and look up `collection_select` and see if there is an option that will prompt the user for input rather than just display the first record. Implement similar functionality for contract_date and published_date (which are not required). After fixing this, I'd recommend you save this work to your git repository.

4.  Of course, we also need to be able to select one or more authors for each book. In the `_form.html.erb` template for books, add in a partial that will create the checkboxes for assigning an author to a book. Add the line

    ```erb
    <%= render partial: 'authors_checkboxes' %>
    ```

    just prior to the submit button in the template.

    Within the `app/views/books` directory, create a new file called `_authors_checkboxes.html.erb` and add to it the following code:

    ```erb
    <%= for author in Author.alphabetical %>
      <%= check_box_tag "book[author_ids][]", author.id, @book.authors.include?(author) %>
      <%= author.name %>
    <%= end %>
    ```

    Note: in Rails 3 and above, `render` assumes by default you are rendering a partial, so you could just say `render 'authors_checkboxes'` here, but I want you to put the `:partial =>` in for now to reinforce the idea of partials.

    If you were to try and submit the data for this form, it would reject the information for the authors (You could check this by looking in the BookAuthor table). We will talk about this later in the course. For now, add `:author_ids` to the list of attributes that your controller will allow to be passed to your Book model. We can find that list in a private method called `book_params` at the bottom of the `BooksController` -- add `:author_ids` there. Because this is an array of ids, we need to let Rails know that with the code below:

    ```ruby
    # controllers/books_controller.rb
    def book_params
      params.require(:book).permit(:title, :year_published, :publisher_id, :author_ids => [])
    end
    ```

5.  In the show template for books, change the `@book.publisher_id` to `@book.publisher.name` so that we are displaying more useful information regarding the publisher. After that, add in a partial that will create a bulleted list of authors for a particular book. To do that, add the line:

    ```erb
    <%= render partial: 'list_of_authors' %>
    ```

    after the publisher information in the template and in the code. Then add a file called `_list_of_authors.html.erb` to the app/views/books directory. Within this new file add the following code:

    ```erb
    <%= pluralize(@book.authors.size, 'Author') %>
    ```

6.  After that, add some books to the system using the web interface. Given the authors added, there are some suggested books listed at the end of this lab, but you can do as you wish. View and edit the books to be sure that everything is worked as intended. Of course, looking at the books index page, we realize it too has issues; fix it so that the publisher's name is listed rather than the id (see previous step if you forgot how) and the books are in alphabetical order by using the alphabetical scope in the appropriate place in the books_controller. (Try it yourself, but see a TA if you are struggling on this last one for more than 5 minutes.)

    **BTW, have you been using git after each step? If not, time to do so...**

7.  Look at the partial `list_of_authors`. There are three things to take note of:

    1.  how the pluralize function adds an 's' at the end of author when there is more than one
    2.  how Ruby loops through the list of authors (note that the erb tags for the 'for' and 'end' tag do not have an equal sign)
    3.  how Rails' link_to tag is used to wrap the author's name in an anchor tag leading back to the author's details page.
8.  Before having the TA sign off, you decide to test the following: go to a book in the system, uncheck all the authors, and save. It saves 'successfully', but the list of authors remains unchanged. **Ouch**. Good thing we are testing this app pretty carefully. How do we fix this? First, we need to realize that this happens because if no values are checked for author_ids, then rails by default just doesn't submit the parameter `book[:author_ids][]`. We can force it to submit an empty array by default by adding to the book form (right after the form_for tag) the following line:

    ```erb
    <%= hidden_field_tag "book[author_ids][]", nil%>
    ```

    Once this is working (test it again to be sure), then you can merge the `interface` branch in git back into the `master` branch.

9.  (Optional, but recommended if you have time left in lab) Having developed the interface for books, go back to the`interface` branch and write your own partial for show template of the authors view so that it added a list of all the books the author has written. (This is very similar to what was done for the show book functionality and those instructions/code can guide you.) Once you know it is working properly, save the code to the repo and merge back into the master branch.

# <span class="mega-icon mega-icon-issue-opened"></span>Stop

Show a TA that you have completed the lab. Make sure the TA initials your sheet.

## On Your Own

This week the "on your own" assignment is to go to [RubyMonk's free Ruby Primer](http://rubymonk.com/learning/books/1) and complete any of the previously assigned exercises you have not yet done. If you are caught up and understand the previous exercises (repeat any you are unsure of), you may if time allows choose any of the other primer exercises and try to get ahead (we will do more of these exercises after the exam). Note: be aware that questions from RubyMonk can and will show up on the exam, so 'doing it on your own' does not mean 'doing it if you want to'.

* * *

## Suggested Books

**Agile Web Development with Rails**

*   Year published: 2011
*   Publisher: Pragmatic Bookshelf
*   Authors:
    *   Sam Ruby
    *   David Hannson
    *   Dave Thomas

**Romeo and Juliet**

*   Year published: 2004
*   Publisher: Washington Square Press
*   Authors:
    *   William Shakespeare

**King Lear**

*   Year published: 2004
*   Publisher: Washington Square Press
*   Authors:
    *   William Shakespeare

**The Divine Comedy**

*   Year published: 1995
*   Publisher: Everyman's Library
*   Authors:
    *   Dante Alighieri

**Pride and Prejudice**

*   Year published: 2001
*   Publisher: Washington Square Press
*   Authors:
    *   Jane Austen
