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
#### Locally

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

#### On Heroku
```
$ heroku apps:create
$ heroku buildpacks:set heroku/ruby
$ git checkout minimal-blog
$ git push heroku minimal-blog:master
$ heroku run bin/rails db:migrate
$ heroku open
```

Post some articles.

```
$ git checkout rename-column
$ git push -f heroku rename-column:master
```

Code is on newer version. Postgres is on older scheme.

Reload the page that shows articles. That will result with an error page.

```
$ heroku logs -t
  :
app[web.1]: ActionView::Template::Error (undefined method `body' for #<Article:0x000055fbbccaa7c0>):
app[web.1]:     10:   <% @articles.each do |article| %>
app[web.1]:     11:     <tr>
app[web.1]:     12:       <td><%= article.title %></td>
app[web.1]:     13:       <td><%= article.body %></td>
app[web.1]:     14:       <td><%= link_to 'Show', article_path(article) %></td>
app[web.1]:     15:       <td><%= link_to 'Edit', edit_article_path(article) %></td>
app[web.1]:     16:       <td><%= link_to 'Destroy', article_path(article),
app[web.1]:
app[web.1]: app/views/articles/index.html.erb:13:in `block in _app_views_articles_index_html_erb___3253650643868770937_47269849744480'
app[web.1]: app/views/articles/index.html.erb:10:in `_app_views_articles_index_html_erb___3253650643868770937_47269849744480'
  :
```

Migrating the database fixes the problem after the down time.

```
$ heroku run bin/rails db:migrate
Running bin/rails db:migrate on ⬢ fast-woodland-11010... up, run.9450 (Free)
== 20181113004745 RenameTextToBody: migrating =================================
-- rename_column(:articles, :text, :body)
   -> 0.0069s
== 20181113004745 RenameTextToBody: migrated (0.0070s) ========================
```

Reload the page. `Text` is now shown as `Body`.

## License
This work is licensed under a <a href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International</a> License based upon the work posted at https://guides.rubyonrails.org/getting_started.html .

"Rails", "Ruby on Rails", and the Rails logo are trademarks of David Heinemeier Hansson. All rights reserved.
