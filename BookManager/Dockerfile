FROM ubuntu:latest
# Install some dependencies we need for Rails and PostgreSQL
RUN apt-get update && apt-get install nodejs postgresql-client -y
RUN apt-get install curl -y
RUN apt-get install libpq-dev -y
RUN apt-get install git -y
# We download and use RVM on our VM to specify Ruby version 
RUN curl -sSL https://get.rvm.io | bash -s stable
SHELL [ "/bin/bash", "-l", "-c" ]
RUN . /etc/profile.d/rvm.sh
RUN rvm install ruby-2.5.7 && rvm use 2.5.7
# Configure the main working directory
RUN mkdir -p /BookManager
WORKDIR /BookManager
ADD . /BookManager
# Copy the Gemfile as well as the Gemfile.lock and install
COPY Gemfile Gemfile.lock ./
# Update our gems with bundler 
RUN gem install bundler
RUN bundle install
# Expose port 3000 to the Docker host, so we can access it
EXPOSE 3000
# The main command to run when the container starts
CMD /bin/bash -l -c "bundle exec rails server -b 0.0.0.0"