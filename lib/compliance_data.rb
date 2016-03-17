require 'aws-sdk'

class ComplianceData
  attr_reader :bucket, :settings

  def initialize(settings)
    raise ArgumentError if settings.nil?
    Aws.config.update(
      region: settings.aws_region,
      credentials: Aws::Credentials.new(settings.aws_access_key,
                                        settings.aws_secret_key))
    @settings = settings
    @bucket = Aws::S3::Bucket.new(settings.aws_bucket)
  end

  def base_name(full_name)
    File.basename (full_name || ''), @settings.results_format
  end

  def full_name(base_name)
    return '' if base_name.nil?
    "#{@settings.results_folder}/#{base_name}#{@settings.results_format}"
  end

  def keys
    projects = @bucket.objects(prefix: @settings.results_folder) || []
    projects.map do |project|
      base_name(project.key)
    end
  end

  def versions(name)
    @bucket.object_versions(prefix: full_name(name))
  end

  def file_for(name, version)
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

  def json_for(file_data)
    if file_data.nil?
      nil
    else
      file_data.body.string
    end
  end
end
