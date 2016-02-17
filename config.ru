require 'bundler/setup'
require 'omniauth-myusa'
require './app'

use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET'] 
use OmniAuth::Builder do
  provider :myusa, ENV['APP_ID'], ENV['APP_SECRET'],
           scope: 'profile.email',
           client_options: {
             site: 'https://staging.my.usa.gov',
             token_url: '/oauth/token'
           }
end

run ComplianceData
