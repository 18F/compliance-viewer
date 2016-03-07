require 'bundler/setup'
require 'omniauth-myusa'
require 'encrypted_cookie'
require './app'

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
