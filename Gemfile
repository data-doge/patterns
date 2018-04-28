source 'https://rubygems.org'
ruby '2.5.1'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
gem 'bootsnap' # for faster booting
gem 'rack-cache'
gem 'airbrake', '~> 5.0' # sends errors to external service
# gem 'pg' # soooooon!
gem 'mysql2'

gem 'hiredis' # faster redis
gem 'redis' # ephemeral storage and caching
gem 'redis-rails' # for session store, I think deprecated in rails 5.2
gem 'validates_overlap' # to ensure we don't double book people

#gem 'rails_12factor' # don't need this. yet. soon!

gem 'mail'

gem 'ransack' # rad searching.

gem 'mandrill-rails' # for inbound email

gem 'awesome_print' # for printing awesomely

gem 'fuzzy_match' # for sms command fuzzy matching

gem 'rails_db' #for data-wonky fellows

gem 'nokogiri', '1.8.2'


group :development do
  # gem 'capistrano'
  # mainline cap is busted w/r/t Rails 4. Try this fork instead.
  # src: https://github.com/capistrano/capistrano/pull/412

  gem 'capistrano', '~> 2.15.4'

  gem 'rvm-capistrano', require: false
  gem 'rbnacl', '~> 4.0.0' # for modern ssh keys
  gem 'rbnacl-libsodium' # same as above
  gem 'bcrypt_pbkdf' # same as above
  # this whole group makes finding performance issues much friendlier
  gem 'flamegraph'
  gem 'memory_profiler'
  gem 'rack-mini-profiler'
  gem 'ruby-prof'
  gem 'stackprof' # ruby 2.1+ only

  # n+1 killer.
  #gem 'bullet'

  # what attributes does this model actually have?
  gem 'annotate'

  # a console in your tests, to find out what's actually happening
  gem 'pry-rails'

  # a console in your browser, when you want to interrogate views.
  gem 'web-console'

  # silences logging of requests for assets
  #gem 'quiet_assets'

  # enabling us to deploy via travis and encrypted keys!
  #gem 'travis'
end

group :production do
  #gem 'newrelic_rpm'
  gem 'skylight' # perf
  gem 'lograge' # sane logs
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby
  gem 'uglifier'
end

gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# To use ActiveModel has_secure_password
gem 'bcrypt'

# Use unicorn as the app server
gem 'unicorn'

# To use debugger
# gem 'debugger'

# https://coderwall.com/p/fnfdgw/useful-regular-expressions-to-update-to-bootstrap-3
gem 'twitter-bootstrap-rails', '~> 2.2.0'
gem 'glyphicons-rails'
gem 'momentjs-rails' # sane time management in js
gem 'bootstrap3-datetimepicker-rails'

# pagniate with will_paginate: https://github.com/mislav/will_paginate
gem 'will_paginate'
gem 'will_paginate-bootstrap', '~> 0.2.5' # Bootstrap 2 support breaks at v1.0

# include health_check, for system monitoring
gem 'health_check'

# use holder for placeholder images
gem 'holder_rails'

# use devise for auth/identity
gem 'devise'

# use gibbon for easy Mailchimp API access
gem 'gibbon'

# use twilio-ruby for twilio
gem 'twilio-ruby', '~> 4.13.0'

# use Wuparty for wufoo
gem 'wuparty'

# Use gsm_encoder to help text messages send correctly
gem 'gsm_encoder'

# use Delayed Job to queue messages
gem 'daemons'
gem 'delayed_job_active_record'

gem "delayed_job_web"

# for generating unique tokens for Person
# gem 'has_secure_token' # not needed in rails 5+

# phone number validation
gem 'phony_rails'

# zip code validation
gem 'validates_zipcode'

# in place editing
gem 'best_in_place', '~> 3.0.1'

# validation for new persons on the public page.
gem 'jquery-validation-rails'

# to validate gift card numbers
gem 'credit_card_validations'

# for automatically populating tags
gem 'twitter-typeahead-rails'

# make ical events and feeds
gem 'icalendar'

# state machine for reservations.
gem 'aasm'

# cron jobs for backups and sending reminders
gem 'whenever', require: false
#gem 'backup', require: false

# handling emoji!
gem 'emoji'

# auditing.
gem 'paper_trail'
gem 'paper_trail-globalid'

gem 'fast_blank' # blank? rewritten in c

gem 'faster_path' #if !`which rustc`.empty?

# storing money with money-rails
gem 'money-rails'

# masked inputs
gem 'maskedinput-rails'

# the standard rails tagging library
gem 'acts-as-taggable-on'


group :test do
  # mock tests w/mocha
  gem 'mocha', require: false

  gem 'sqlite3', platform: %i[ruby mswin mingw]

  ## for JRuby
  # gem 'jdbc-sqlite3', platform: :jruby
  gem 'memory_test_fix' # in memory DB, for the speedy

  # generate fake data w/faker: http://rubydoc.info/github/stympy/faker/master/frames
  #gem 'codeclimate-test-reporter'
  gem 'coveralls', require: false
  gem 'faker'
  gem 'rubocop', require: false
  gem 'simplecov', require: false
  # screenshots when capybara fails
  #gem 'capybara-screenshot'

  # retry poltergeist specs. they are finicky
  gem 'rspec-retry'

  # calendaring tests will almost always break on saturdays.
  gem 'timecop'

  # webrick is slow, capybara will use puma instead
  gem 'puma'

  # in memory redis for testing only
  gem 'mock_redis'
end

group :development, :test do
  gem 'capybara'
  #gem 'capybara-email'
  gem 'database_cleaner'
  gem 'factory_girl_rails', require: false
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-minitest'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop'
  #gem 'poltergeist'
  gem 'pry' # a console anywhere!
  gem 'rspec-rails', '~> 3.0'
  gem 'shoulda-matchers', '~> 3.1.1', require: false
  gem 'sms-spec'
end
