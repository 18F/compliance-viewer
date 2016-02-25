require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'aws-sdk'
require 'json'

class ComplianceData < Sinatra::Base
  register Sinatra::ConfigFile

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

  get '/results/:name/current' do |name|
    file_data = get_file(name, nil)
    if file_data.nil?
      'Invalid Version'
    else
      erb :report, locals: { report_data: create_report(file_data) }
    end
  end

  get '/results/:name/:version' do |name, version|
    file_data = get_file(name, version)
    if file_data.nil?
      'Invalid Version'
    else
      erb :report, locals: { report_data: create_report(file_data) }
    end
  end

  get '/results/:name/raw/:version' do |name, version|
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
    rescue Aws::S3::Errors::InvalidArgument,
           Aws::S3::Errors::NoSuchVersion,
           Aws::S3::Errors::NoSuchKey
      puts 'Unable to find file'
    end
    file_data
  end

  def create_report(file_data)
    report_data = {}
    parsed_data = JSON.parse file_data.body.string
    report_data['summary'] = create_report_summary parsed_data
    report_data['alerts'] = create_report_alerts parsed_data
    report_data
  end

  def create_report_alerts(file_data)
    alerts = {}
    file_data.each do |a|
      alert = a['alert']
      alerts[alert] = create_alert_record(a) unless alerts.key? alert
      alerts[alert]['instances'] = [] unless alerts[alert].key? 'instances'
      alerts[alert]['instances'].push create_alert_instance(a)
    end
    alerts
  end

  def create_alert_instance(alert_data)
    {
      'url' => alert_data['url'],
      'parameter' => alert_data['param'],
      'attack' => alert_data['attack'],
      'evidence' => alert_data['evidence']
    }
  end

  def create_alert_record(alert_data)
    {
      'risk' => alert_data['risk'],
      'confidence' => alert_data['confidence'],
      'description' => alert_data['description'],
      'solution' => alert_data['solution'],
      'other' => alert_data['other'],
      'reference' => alert_data['reference'],
      'cweid' => alert_data['cweid'],
      'wascid' => alert_data['wascid']
    }
  end

  def create_report_summary(file_data)
    levels = Hash.new 0
    file_data.each { |a| levels[a['risk']] += 1 }
    levels
  end
end
