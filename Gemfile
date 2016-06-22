source 'https://rubygems.org'

# the application should support a broader range of versions than this, but
# https://github.com/rvm/rvm/issues/3705
ruby '2.3.1'

gem 'sinatra'
gem 'sinatra-contrib'
gem 'unicorn'
gem 'aws-sdk'
gem 'cfenv'
gem 'parallel'
gem 'sprockets'
gem 'sprockets-helpers'
gem 'sass'
gem 'uglifier'

group :test, :development do
  gem 'rspec'
  gem 'rubocop'
  gem 'simplecov'
  gem 'mocha'
end

group :test do
  gem 'webmock'
end

gem 'codeclimate-test-reporter', group: :test, require: nil
