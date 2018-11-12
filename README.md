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

## License
This work is licensed under a <a href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International</a> License based upon the work posted at https://guides.rubyonrails.org/getting_started.html .

"Rails", "Ruby on Rails", and the Rails logo are trademarks of David Heinemeier Hansson. All rights reserved.
