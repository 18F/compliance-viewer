require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'aws-sdk'
require 'json'
require_relative 'lib/zap_report'

class ComplianceData < Sinatra::Base
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
    Aws.config.update(
      region: settings.aws_region,
      credentials: Aws::Credentials.new(settings.aws_access_key,
                                        settings.aws_secret_key))

    @s3 = Aws::S3::Resource.new
    @bucket = @s3.bucket(settings.aws_bucket)
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
    erb :index, locals: { projects: key_list }
  end

  get '/results' do
    erb :index, locals: { projects: key_list }
  end

  get '/results/:name' do |name|
    versions = get_version_list name
    'Invalid Project' if versions.count == 0
    erb :results, locals: { versions: versions }
  end

  get '/results/:name/:version' do |name, version|
    version = nil if version == 'current'
    file_data = get_file(name, version)
    if file_data
      if params['format'] == 'json'
        attachment "#{name}#{settings.results_format}"
        file_data.body.string
      else
        erb :report, locals: { report_data: ZapReport.create_report(file_data) }
      end
    else
      'Invalid Version'
    end
  end

  def base_name(full_name)
    File.basename full_name, settings.results_format
  end

  def full_name(base_name)
    "#{settings.results_folder}/#{base_name}#{settings.results_format}"
  end

  def key_list
    projects = []
    @bucket.objects(prefix: settings.results_folder).each do |project|
      projects.push base_name(project.key)
    end
    projects
  end

  def get_version_list(name)
    @bucket.object_versions(prefix: full_name(name))
  end

  def get_file(name, version)
    file_data = nil
    begin
      file_data = @bucket.object(full_name(name)).get(version_id: version)
    rescue Aws::S3::Errors::InvalidArgument,
           Aws::S3::Errors::NoSuchVersion,
           Aws::S3::Errors::NoSuchKey
      puts 'Unable to find file'
    end
    file_data
  end
end
