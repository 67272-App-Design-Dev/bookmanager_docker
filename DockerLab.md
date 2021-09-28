
## Part 1: Setup

1. Install Docker Desktop on your local machine by following the instructions for your respective operating system [here](https://docs.docker.com/get-docker/).
2. Install PostgreSQL if you do not already have it [here](https://www.postgresql.org/download/)
3. Clone othe starting [repository](https://github.com/67272-App-Design-Dev/bookmanager_docker.git)


## Part 2: Docker Introduction 
### Docker Architecture
[Docker](https://docs.docker.com/get-started/overview/) is a platform for developing, shipping, and running applications. Docker allows you to create containers which are environments fit to the specifications needed to run your apps. The platform allows you to run multiple containers simultaneously on a single operating system. The architecture differences between machine virtualizations and containers are highlighted in the following diagram.

![](https://imgur.com/kBBlpZl.png)
In this diagram, Docker is the container engine.

### Docker Images and Containers

1. We are going to start by creating a file called `Dockerfile` at the root of our Rails project. Ensure that this file has no extension or Docker will not recognize it. 
2. Paste in the following contents: 

	``` 
	FROM ubuntu:latest
	# Install some dependencies we need for Rails and PostgreSQL
	RUN apt-get update && apt-get install nodejs postgresql-client -y
	RUN apt-get install curl -y
	RUN apt-get install libpq-dev -y
	# We download and use RVM on our VM to specify Ruby version 
	RUN curl -sSL https://get.rvm.io | bash -s stable
	SHELL [ "/bin/bash", "-l", "-c" ]
	RUN . /etc/profile.d/rvm.sh
	RUN rvm install ruby-2.5.7 && rvm use 2.5.7
	``` 
	
	Read through the contents and comments in the file to understand how our image is being built. Docker can build images by reading instructions in this file. In the case above we are specifying a base linux image, installing some dependencies, and installing RVM to adjust our Ruby version.
	
3. Now lets create a Docker image by running `docker build -t bookmanager .` from our project's root directory. Observe that we are building a base image with the specifications in `Dockerfile`. Note that the `t` flag allows us to associate a name with our image. Verify the image was created by opening Docker dashboard and checking the images folder.

4. Now lets start a container from the image we just created with the `docker run` command. Run the following: 

	```
	docker run --name bookmanager -dp --rm bookmanager
	```
	
	Note that with the `d` flag we are running the container in "detached mode". The `rm` flag simply cleans up the container Docker is using after the container exits.
	
5. Go to the dashboard and enter the CLI for the container. Verify that our Ruby version is correct with `ruby --version`.

6. Now we have container fit to our specifications to be able to run our app. Let's now add our app by adding it to the image used to build the container and running a new instance. Add the following to the end of `Dockerfile`:

   ``` 
   # Configure the main working directory
	RUN mkdir -p /BookManager
	WORKDIR /BookManager
	ADD . /BookManager
	# Copy the Gemfile as well as the Gemfile.lock and install
	COPY Gemfile Gemfile.lock ./
	# Update our gems with bundler 
	RUN gem install bundler
	RUN bundle install
	RUN bundle exec rails db:reset
	# Expose port 3000 to the Docker host, so we can access it
	EXPOSE 3000
	# The main command to run when the container starts
	CMD /bin/bash -l -c "bundle exec rails server -b 0.0.0.0"
   ```
	
	Note how we are copying adding our app and also running some additional 	commands like installing our gems and initializing the database. We also 	specify with the `CMD` key to start our Rails app when a container 	with our image launches.
 
7. Let's stop the previous instance of the container from the dashboard or with the command `docker stop bookmanager`, and run the following to create a new instance: 
 
   ```
   docker run --name bookmanager -dp 3000:3000 --rm bookmanager
   ```
   
	Note that we are now specifying the `p` flag which binds the container's 	port 3000 to our local machine's port 3000. Our container will run our Rails 	application on port 3000 and we want to be able to access it from our local 	machine.
   
8. Now verify that you can visit the application on your local computer at port 3000. Visit the authors page and add some entries.

9. Stop the container instance and create another using the `docker build` command like before 

10. Navigate to the books page and add some books for our authors made in the previous step


### Persisting our Database

Did you notice each time we start a container the new entries are wiped clean? Containers get their own file space so any changes we make in one will not be seen in another. Though, there is a way to persist our data from one container to the next. Volumes give us the ability to connect a filesystem from our machine to the container so we can access the data after the container exits and possibly connect the same filesystem to our next container instance.

1. Create a new volume with the `docker volume create` command:

	```
	docker volume create my-vol
	```
	
   You can verify the volume was created in the Docker dashboard.
   
2. Start another instance of the container, but this time use the `v` flag to specify our volume:

	 ```
	 docker run --name bookmanager -dp 3000:3000 \
	 -v my-vol:/BookManager/db/ --rm bookmanager
	 ```
	 Note if you did not stop the container instance from the previous part you 	 will get an error since both container instances will attempt to bind to 	 our local port 3000 at the same time.
	 
3. Our volume is mounted to the `db` directory in our application. This is the default directory where our database is stored. Go ahead and add some items in the application. 
4. Stop the container instance and relaunch another container instance with the same volume to see your data persist across launches!


### Using Bind Mounts

In the last section, we used a named volume to persist our database between container runs. This is useful if we do not care about where our data is stored. If we do, then we can use [bind mounts](https://docs.docker.com/storage/bind-mounts/). This will allow us actually mount a local host directory into our container! This type of volume can be used to persist data but also to help speed up our development by mounting our source code and allowing the container to respond to changes immediately.
	
![Image](https://imgur.com/LzRMA9k.png)

Docker containers can be configured with three different types of mounts. The main difference between bind mounts and volumes is that the user can specify the location of the filesystem on the local computer with a bind mount. tmpfs mounts are for linux users only and allow for the container to create files outside the container's writable layer. 

1. Lets create another instance of our container, but this time instead of using our volume we will bind our working directory on our local machine to the working directory of the Docker container. From the root of our app run:

	```
	docker run --name bookmanager -dp 3000:3000 \
	-v "$(pwd):/BookManager" --rm bookmanager
	```
	
2. Go to the publishers page and add in some publishers. Notice how we do not have the option to show the individual publisher pages.
3. Paste in the following contents to `index.html.erb` in our publishers folder below `<td><%= publisher.name %></td>`: 

	```
	<td><%= link_to 'Show', publisher %></td>
	```
4. Now reload the page and observe the new show option. Now we can make edits to our app that are immediately refelected in our container!

## Part 3: Multiple Containers 

### Multi-Container Applications 

We have been using one container up until now to run our Rails application. Best practices often involve using mutliple containers for different parts of the app. There are numerous advantages to doing this: 

* Separate containers allow for versioning and updating each part in isolation 
* We may only deploy some parts of our app in production while using some exclusively for development or testing 
* We can reduce complexity and increase start-up time
* Some services may require drasticly different dependencies or even operating systems to be able to run 

In general, a separate container should be used for each function of our app. 

We will now create two containers for our database and frontend respectively. 

1. Services in separate containers can only communicate with each other if they are on the same network. Create a network for our two containers:
	
	``` 
	docker network create bookmanager
	```	
	
2. Instead of creating another image for our database container to use, we are going to pull and use the official image released by PostgreSQL. Run the following to pull the image: 

	```
	docker pull postgres
	``` 
3. Now run the following to launch a container from the image:

	```
	docker run -d --rm --name bookmanager_db \
	--network bookmanager --network-alias db \
	-v $(pwd)/tmp/db:/var/lib/postgresql/data \
	-e POSTGRES_USERNAME=postgres -e POSTGRES_PASSWORD=secret postgres
	```	
	Note we are specifying a network and alias during this run and passing in some environment variables for verification with our database. We are also specifying a bind mount to persist our database. 
	
4. Now, our database is up and running and can be accessed by services in other containers on the same network. Let's edit our app to use PostgreSQL. Add `gem "pg"` to your gem file, run `bundle install`, and paste the following into your `database.yml` file:
 
	```
	default: &default
		adapter: postgresql
		encoding: unicode
		host: db
		username: postgres
		password: secret
		pool: 5
	
	development:
		<<: *default
		database: bookmanager_development
	
	test:
		<<: *default
		database: bookmanager_test
	
	production:
		<<: *default
		database: bookmanager_production
	```
	
	Note how we are using the username and password that we passed as environment variables to our database container and also specifying the alias as our host.
	
5. Now update our container image with the `docker build` command and run a container with our updated image, but this time include a network specification: 

	```
	docker run --name bookmanager_web --network bookmanager \
	-dp 3000:3000 -v "$(pwd):/BookManager" --rm bookmanager
	```
6. Verify that there are two containers running our images with the `docker ps` command or in the Docker dashboard.
7. If this is the first time running our app, our database will need to be created. This can be done by entering the command line in our PostgreSQL container or by going to the command line for our rails app. Go to the CLI of the Rails app through the dashboard or with the command `docker exec -it bookmanager_web /bin/bash` to run our container in the foreground and then run `/bin/bash -l -c "bundle exec rails db:migrate:reset"` to set up our database.


### Docker Compose 

Now we know how to connect services in different containers over the same network. Though, the process of deploying these containers is cumbersome and can become difficult as we add more and more. That is where [Docker Compose](https://docs.docker.com/compose/) comes in. Stop both containers from the previous part.

1. At the root of the app create a file called `docker-compose.yml`.
2. Paste in the following contents:

	```
	version: '3'
	services:
	  db:
	    image: postgres
	    volumes:
	      - ./tmp/db:/var/lib/postgresql/data
	  web:
	    image: bookmanager
	    volumes:
	      - .:/BookManager
	    ports:
	      - "3000:3000"
	    depends_on:
	      - db
	```
	Note how we are essentially specifying the same parameters we did in the individual calls to run our contains but now compiling the commands into a single file. We do not need to specify a network because the compose service sets up and attaches all of our services to a single network by default.
	
3. Run `docker-compose up` from the project's root directory to launch our app. The app can be torn down by running `docker-compose down`. 

4. Verify that our bind mount volumes still work by adding some entries to the app, tearing it down, launching it again, and checking the entries are still present. Also, make some updates to the project in our root directory and verify the updates take effect immediately in the app.
  

### Clean up Resources

Run the following to clean up any unused or dangling containers, images, and volumes: 

```
docker system prune --volumes
```

## Summary

To summarize what we did in this lab we were able to: 

* Build an image suitable to run our app from specifications in our `dockerfile`
* Launch a container from our image 
* Persist our database between instances of containers 
* Bind our container to our working directory to see immediate changes and speed up development 
* Separate the database and frontend of our app into different containers 
* Use `docker-compose` to quickly deploy all the containers for all of the services of our app
	
	