require 'bundler/setup'
require 'encrypted_cookie'
require 'cfenv'
require 'sprockets'
require './app'

unless ENV['RACK_ENV'] == 'production'
  # use local configuration file
  ENV['VCAP_SERVICES'] = File.read("#{__dir__}/env/#{ENV['RACK_ENV']}.json")
end
creds = Cfenv.service('user-provided').credentials

cookie_settings = {
  secret: creds.cookie_secret,
  httponly: true
}
use Rack::Session::EncryptedCookie, cookie_settings

map '/assets' do
  run ComplianceViewer.assets
end

run ComplianceViewer
