source 'https://rubygems.org'

ruby '2.2.3'

gem 'sinatra'
gem 'sinatra-contrib'
gem 'unicorn'
gem 'aws-sdk'
gem 'omniauth'
gem 'omniauth-myusa', git: 'https://github.com/18F/omniauth-myusa.git'
gem 'encrypted_cookie'
gem 'cfenv'
gem 'parallel'
gem 'sprockets'
gem 'sprockets-helpers'
gem 'sass'

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
