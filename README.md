# A sample minimal blog app
This is a minimal blog app built on Ruby on Rails following https://guides.rubyonrails.org/getting_started.html to demonstrate database migrations on Heroku.

Note: Some Ruby Gems used in this project have known vulnerabilities but intentionally left as they are to preserve commit graph in the repository. Make sure to update gems if you're using this repository for your project.

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

#### On Heroku, with Release Phase command
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
$ git checkout rename-column-release-phase
$ git push -f heroku rename-column-release-phase:master
```

The Release Phase command has a 60-second sleep to make the versin mismatch more visible. Reload the page after the Reload Phase command completed database migration but before dynos are restarted for the release.

```
$ heroku logs -t
  :
2018-11-15T01:07:15.651153+00:00 heroku[release.1058]: Starting process with command `if curl https://heroku-release-output.s3.amazonaws.com/log-stream?... --silent --connect-timeout 10 --retry 3 --retry-delay 1 >/tmp/log-stream; then   chmod u+x /tmp/log-stream   /tmp/log-stream /bin/sh -c 'bin/rails db:migrate; sleep 60' else   bin/rails db:migrate; sleep 60 fi`
2018-11-15T01:07:16.293342+00:00 heroku[release.1058]: State changed from starting to up
  :
ActionView::Template::Error (missing attribute: text):
    10:   <% @articles.each do |article| %>
    11:     <tr>
    12:       <td><%= article.title %></td>
    13:       <td><%= article.text %></td>
    14:       <td><%= link_to 'Show', article_path(article) %></td>
    15:       <td><%= link_to 'Edit', edit_article_path(article) %></td>
    16:       <td><%= link_to 'Destroy', article_path(article),
```

When the dyno has restarted, the page will show fine again.

### Add a column before the code change
This allows the app keep running while the database migration.

#### Locally
```
$ git checkout minimal-blog
$ git reset --hard
$ bin/rails db:drop
$ bin/rails db:setup
$ bin/rails server
```

Create some articles.

Add the `body` column:

```
$ git checkout add-and-delete-column-1
$ git reset --hard
$ bin/rails db:migrate
== 20181115023021 AddBodyToArticles: migrating ================================
-- add_column(:articles, :body, :text)
   -> 0.0018s
-- execute("UPDATE articles SET body = text;\nCREATE OR REPLACE FUNCTION sync_to_body()\n  RETURNS TRIGGER AS $$\n  BEGIN\n    IF NEW.body IS NULL THEN\n      NEW.body := NEW.text;\n    END IF;\n    RETURN NEW;\n  END;\n  $$ LANGUAGE plpgsql;\n\nCREATE TRIGGER sync_to_body_trigger\n  BEFORE INSERT OR UPDATE OF text ON articles\n  FOR EACH ROW EXECUTE PROCEDURE sync_to_body();\n")
   -> 0.0233s
== 20181115023021 AddBodyToArticles: migrated (0.0254s) =======================
```

Stop the rails server and change the code to refer to `body` column:

```
$ git checkout add-and-delete-column-2
$ git reset --hard
$ bin/rails server
```

Now, only the `body` column is referred to.

Finally, drop the `text` column:

```
$ git checkout add-and-delete-column-3
$ git reset --hard
$ bin/rails db:migrate
== 20181116211017 DropTextFromArticles: migrating =============================
-- execute("DROP TRIGGER sync_to_body_trigger ON articles;\nDROP FUNCTION sync_to_body();\n")
   -> 0.0014s
-- remove_column(:articles, :text)
   -> 0.0016s
== 20181116211017 DropTextFromArticles: migrated (0.0034s) ====================

$ bin/rails server
```

### On Heroku

```
$ heroku apps:create
$ heroku buildpacks:set heroku/ruby
$ git checkout minimal-blog
$ git push heroku minimal-blog:master
$ heroku run bin/rails db:migrate
$ heroku open
```

Post some articles.

Start renaming the column. First, push the migration to add the column.

```
$ git checkout add-and-delete-column-1
$ git push -f heroku add-and-delete-column-1:master
```

Post and/or edit some articles. Then, migrate the database.

```
$ heroku run bin/rails db:migrate
```

Post and/or edit some articles. Change the code to use the new column.

```
$ git checkout add-and-delete-column-2
$ git push -f heroku add-and-delete-column-2:master
```

Wait for the dyno to restart.
Now the pages show Body instead of Text.
Post and/or edit some articles.

Finally, remove the old column.

```
$ git checkout add-and-delete-column-3
$ git push -f heroku add-and-delete-column-3:master
$ heroku run bin/rails db:migrate
```

## License
This work is licensed under a <a href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International</a> License based upon the work posted at https://guides.rubyonrails.org/getting_started.html .

"Rails", "Ruby on Rails", and the Rails logo are trademarks of David Heinemeier Hansson. All rights reserved.
