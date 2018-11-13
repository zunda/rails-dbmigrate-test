# A sample minimal blog app
This is a minimal blog app built on Ruby on Rails following https://guides.rubyonrails.org/getting_started.html to demonstrate database migrations on Heroku.

## Running locally
Run a PostgreSQL server locally and execute the following:

```
$ bundle install --path=vendor/bundle
$ bin/rails db:setup
```

Run the following to start the server

```
$ bin/rails server
```

and navigate to http://localhost:3000/

## Deploy to Heroku
Click the Heroku button:
[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Different paths to rename the column
### Use rename_column

```
$ git checkout minimal-blog
$ git reset --hard
$ bin/rails db:drop
$ bin/rails db:setup
$ psql rails-dbmigrate-test_development
rails-dbmigrate-test_development=# \d articles
                                        Table "public.articles"
   Column   |            Type             | Collation | Nullable |               Default                
------------+-----------------------------+-----------+----------+--------------------------------------
 id         | bigint                      |           | not null | nextval('articles_id_seq'::regclass)
 title      | character varying           |           |          | 
 text       | text                        |           |          | 
 created_at | timestamp without time zone |           | not null | 
 updated_at | timestamp without time zone |           | not null | 
Indexes:
    "articles_pkey" PRIMARY KEY, btree (id)
```

```
$ git checkout rename-column
$ git reset --hard
$ bin/rails db:migrate
== 20181113004745 RenameTextToBody: migrating =================================
-- rename_column(:articles, :text, :body)
   -> 0.0241s
== 20181113004745 RenameTextToBody: migrated (0.0244s) ========================
$ psql rails-dbmigrate-test_development
rails-dbmigrate-test_development=# \d articles
                                        Table "public.articles"
   Column   |            Type             | Collation | Nullable |               Default                
------------+-----------------------------+-----------+----------+--------------------------------------
 id         | bigint                      |           | not null | nextval('articles_id_seq'::regclass)
 title      | character varying           |           |          | 
 body       | text                        |           |          | 
 created_at | timestamp without time zone |           | not null | 
 updated_at | timestamp without time zone |           | not null | 
Indexes:
    "articles_pkey" PRIMARY KEY, btree (id)
```

## License
This work is licensed under a <a href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International</a> License based upon the work posted at https://guides.rubyonrails.org/getting_started.html .

"Rails", "Ruby on Rails", and the Rails logo are trademarks of David Heinemeier Hansson. All rights reserved.
