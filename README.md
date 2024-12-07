# README

## Chat system API Endpoint (Ruby on Rails)

### Git Workflow
Used Feature Branch Workflow which helped me manage code changes by isolating new features in seperate branches, squaching commits for clarity and merging cleanly into main branch.

### Designs
#### System Design Diagram
![Alt text](<Chat-system.drawio.png>)

#### Database Design
![Alt text](image-1.png)

Note: Database in utf8 to support Arabic

Relations:

* Applications Table:

  - > 1 to many relation with Chats table.

  - > 1 to many relation with Messages table.

    - As shown in the design, I used the ```token``` column as an index to facilitate searching for specific applications.


* Chat Table:

  - > 1 to many relation with Messages table.

    - Forgein key for Applications Table is ```application_token```
    - I made the combination of ```application_token``` and ```number``` columns unique to ensure that chat numbering within each application starts from 1, with no duplicate numbers in the same application.

* Messages Table:

    - Forgein key for Applications Table is ```application_token```
    - Forgein key for Chats Table is ```chat_number```
    - I made the combination of ```application_token```, ```number``` and ```chat_number``` columns unique to ensure that chat numbering within each application starts from 1, with no duplicate numbers in the same application.

Note: I designed a database where data is injected in a sorted way, which leads to faster query performance, efficient range searches, and reduced sorting overhead during retrieval. This approach also optimizes indexing, simplifies pagination, and improves storage efficiency through better compression.


#### ElasticSearch
![Alt text](<elasticsearch logo.png>)

I integrated Elasticsearch to index message content. Whenever a user inserts or updates a message, the data is stored in Elasticsearch.

After looking up on how to do efficient partial search, I used the ```edge_ngram_tokenizer``` tokenizer. This tokenizer breaks down the message content into substrings, allowing for faster and more accurate partial matching when searching for keywords. I also returned the data highlighted for good visialization


#### Redis
![Alt text](Redis-Logo.wine.png)

I utilized Redis in my application as an in-memory data store to manage chat counts and message counts efficiently. Redis was used to cache the counts, reducing database load and improving performance.

  - Chat Counts: Stored using a key like ```application_token:chat_count``` to track the total chats for each application.
  - Message Counts: Stored with keys like ```application_token:chat_number:message_count``` to track the messages in each chat.

I indexed these keys and values when doing actions create and index of Chats and Messages of a certain ```application_token```  

By doing this, I can continuously track the number column for newly created chats or messages. This setup minimized the need for frequent database queries, ensuring fast and scalable operations.


### My Routes
![Alt text](image.png)

##Requirements

install [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/install/).

## Getting started

### For Docker

To build and start 
```
docker-compose up --build
```
Migrate database (Note: you may need to do this step)
```
docker-compose run web rake db:migrate
```

To stop using the app
```
docker-compose down
```

Note: you need to enter data in this order ```Applications > Chats > messages```

## Rspec 

After building and starting docker you need to enter Bash of web continer
```
docker exec -it chat-system-web-1 bash
```
Then type
```
bundle exec rspec
```

## Where to find

* Database schema
> db/schema.rb

* Models
> app/models

* Controllers 
> app/controllers/api/v1

* Sidekiq (Job - Worker)
> app/sidekiq/update_database_counters_job.rb

* Routes
> config/routes.rb

* Docker
> Dockerfile
> docker-compose.yml

* Routes
> config/routes.rb

* spec
> spec/*

* Routes
> config/routes.rb

* Routes
> config/routes.rb
