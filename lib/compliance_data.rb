require 'aws-sdk'
require 'cfenv'

class ComplianceData
  attr_reader :bucket

  def initialize
    Aws.config.update(
      region: user_credentials.aws_region,
      credentials: Aws::Credentials.new(s3_credentials.access_key_id, s3_credentials.secret_access_key)
    )

    @bucket = Aws::S3::Bucket.new(s3_credentials.bucket)
  end

  def base_name(full_name)
   File.basename (full_name || ''), results_format
  end

  def full_name(base_name)
   return '' if base_name.nil?
   "#{results_folder}/#{base_name}#{results_format}"
  end

  def keys
    projects = @bucket.objects(prefix: results_folder) || []
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

  private

  def s3_credentials
    Cfenv.service('s3').credentials
  end

  def user_credentials
    Cfenv.service('user-provided').credentials
  end

  def results_folder
    user_credentials.results_folder
  end

  def results_format
    user_credentials.results_format
  end
end
