require 'aws-sdk'

class ComplianceData
  def initialize
    Aws.config.update(
      region: ENV['AWS_REGION'],
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
    )

    @bucket = Aws::S3::Bucket.new(ENV['AWS_BUCKET'])
  end

  def base_name(full_name)
   File.basename (full_name || ''), ENV['RESULTS_FORMAT']
  end

  def full_name(base_name)
   return '' if base_name.nil?
   "#{ENV['RESULTS_FOLDER']}/#{base_name}#{ENV['RESULTS_FORMAT']}"
  end

  def keys
    projects = @bucket.objects(prefix: ENV['RESULTS_FOLDER']) || []
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
