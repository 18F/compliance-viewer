require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'json'
require_relative 'lib/zap_report'
require_relative 'lib/compliance_data'

class ComplianceViewer < Sinatra::Base
  attr_reader :compliance_data
  register Sinatra::ConfigFile
  include ZapReport

  config_file 'credentials.yml'

  helpers do
    def authed?
      !session[:user_email].nil?
    end
  end

  def initialize
    super
    @compliance_data = ComplianceData.new settings
  end

  get '/auth/myusa/callback' do
    halt(401, 'Not Authorized') unless env['omniauth.auth']
    session[:user_email] = env['omniauth.auth'].info.email
    redirect '/'
  end

  before %r{^(?!\/auth)} do
    redirect '/auth/myusa' unless authed?
  end

  get '/' do
    erb :index, locals: { projects: compliance_data.key_list }
  end

  get '/results' do
    erb :index, locals: { projects: compliance_data.key_list }
  end

  get '/results/:name' do |name|
    versions = compliance_data.get_version_list name
    'Invalid Project' if versions.count == 0
    erb :results, locals: { versions: versions }
  end

  get '/results/:name/:version' do |name, version|
    version = nil if version == 'current'
    file_data = compliance_data.get_file(name, version)
    if file_data
      if params['format'] == 'json'
        attachment "#{name}#{settings.results_format}"
        compliance_data.get_json file_data
      else
        erb :report, locals: { report_data: ZapReport.create_report(file_data) }
      end
    else
      'Invalid Version'
    end
  end
end
