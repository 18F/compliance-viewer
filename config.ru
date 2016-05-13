require 'bundler/setup'
require 'cfenv'
require 'sprockets'
require './app'

unless ENV['RACK_ENV'] == 'production'
  # use local configuration file
  ENV['VCAP_SERVICES'] = File.read("#{__dir__}/env/#{ENV['RACK_ENV']}.json")
end

map '/assets' do
  run ComplianceViewer.assets
end

run ComplianceViewer
