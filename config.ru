require 'bundler/setup'
require 'omniauth-myusa'
require 'encrypted_cookie'
require './lib/vcap_env'
require './app'

# Set ENV from CloudFoundry UserProvidedService JSON when in production.
#  In other envs use pre-configured JSON
if ENV['RACK_ENV'] == 'production'
  VcapEnv.set_env(ENV['VCAP_SERVICES'])
else
  VcapEnv.set_env(File.read("#{__dir__}/env/#{ENV['RACK_ENV']}.json"))
end

cookie_settings = {
  secret: ENV['COOKIE_SECRET'],
  httponly: true
}
use Rack::Session::EncryptedCookie, cookie_settings

use OmniAuth::Builder do
  provider :myusa, ENV['APP_ID'], ENV['APP_SECRET'],
           scope: 'profile.email',
           client_options: {
             site: 'https://staging.my.usa.gov',
             token_url: '/oauth/token'
           }
end

run ComplianceViewer
