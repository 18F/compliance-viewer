require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'aws-sdk'

class ComplianceData < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'credentials.yml'

  helpers do
    def authed?
      session[:authenticated]
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

  get '/' do
    if authed?
      erb :index, locals: { projects: key_list }
    else
      redirect '/auth/myusa'
    end
  end

  get '/auth/myusa/callback' do
    auth = env['omniauth.auth']
    if auth
      session[:user_email] = auth.info.email
      session[:authenticated] = true
    else
      halt(401, 'Not Authorized')
    end
    redirect '/'
  end

  get '/results' do
    if authed?
      erb :index, locals: { projects: key_list }
    else
      redirect '/auth/myusa'
    end
  end

  get '/results/:name' do |name|
    halt(401, 'Not Authorized') unless authed?
    versions = get_version_list name
    'Invalid Project' if versions.count == 0
    erb :results, locals: { versions: versions }
  end

  get '/results/:name/:version' do |name, version|
    halt(401, 'Not Authorized') unless authed?
    file_data = get_file(name, version)
    if file_data.nil?
      'Invalid Version'
    else
      attachment "#{name}#{settings.results_format}"
      file_data.body.string
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
    rescue Aws::S3::Errors::InvalidArgument => msg
      puts msg
    rescue Aws::S3::Errors::NoSuchVersion => msg
      puts msg
    end
    file_data
  end
end
