require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
require_relative 'lib/zap_report'
require_relative 'lib/compliance_data'

class ComplianceViewer < Sinatra::Base
  attr_reader :compliance_data
  include ZapReport

  helpers do
    def authed?
      !session[:user_email].nil?
    end
  end

  def initialize
    super
    @compliance_data = ComplianceData.new
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
    erb :index, locals: { projects: @compliance_data.keys }
  end

  get '/results' do
    erb :index, locals: { projects: @compliance_data.keys }
  end

  get '/results/:name' do |name|
    versions = @compliance_data.versions(name)
    return 'Invalid Project' if versions.count == 0
    erb :results, locals: { versions: versions }
  end

  get '/results/:name/:version' do |name, version|
    version = nil if version == 'current'
    file_data = @compliance_data.file_for(name, version)
    if file_data
      if params['format'] == 'json'
        attachment "#{name}#{ENV['RESULTS_FORMAT']}"
        @compliance_data.json_for file_data
      else
        erb :report, locals: { report_data: ZapReport.create_report(file_data) }
      end
    else
      'Invalid Version'
    end
  end
end
