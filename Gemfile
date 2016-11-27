source 'https://rubygems.org'

# the application should support a broader range of versions than this, but
# https://github.com/rvm/rvm/issues/3705
ruby '2.3.1'

gem 'aws-sdk'
gem 'cfenv'
gem 'parallel'
gem 'rack'
gem 'sass'
gem 'sinatra-contrib'
gem 'sinatra'
gem 'sprockets-helpers'
gem 'sprockets'
gem 'uglifier'
gem 'unicorn'

group :test, :development do
  gem 'mocha'
  gem 'rspec'
  gem 'rubocop'
  gem 'simplecov'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'webmock'
end
