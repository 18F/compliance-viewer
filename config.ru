require 'bundler/setup'
require 'omniauth-myusa'
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

use OmniAuth::Builder do
  provider :myusa, creds.app_id, creds.app_secret,
    scope: 'profile.email',
    client_options: {
      site: 'https://alpha.my.usa.gov',
      token_url: '/oauth/token'
    }
end

map '/assets' do
  run ComplianceViewer.assets
end

run ComplianceViewer
