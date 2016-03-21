module StubClasses
  class StubBody
    def initialize(alerts = [])
      @alerts = alerts
    end

    def string
      @alerts.to_json
    end
  end

  class StubFile
    attr_reader :body
    def initialize(alerts = [])
      @body = StubBody.new(alerts)
    end
  end

  class StubObjectSummary
    attr_reader :key
    def initialize(key_value)
      @key = key_value
    end
  end

  class StubObjectVersion
    attr_reader :key, :id, :last_modified, :size
    def initialize(key_value)
      @key = key_value
      @id = rand 100
      @last_modified = Time.now
      @size = rand 100
    end
  end

  module StubSettings
    def self.aws_region
      'region'
    end

    def self.aws_access_key
      '123'
    end

    def self.aws_secret_key
      '234'
    end

    def self.aws_bucket
      "bucket#{rand(100)}"
    end

    def self.results_format
      '.json'
    end

    def self.results_folder
      'results'
    end
  end

  class ComplianceDataStub
    def keys
      %w(abc bcd)
    end

    def versions(name)
      if name == 'good'
        [
          StubClasses::StubObjectVersion.new(name),
          StubClasses::StubObjectVersion.new(name),
          StubClasses::StubObjectVersion.new(name)
        ]
      else
        []
      end
    end

    def base_name(name)
      name
    end

    def file_for(_name, version)
      return StubClasses::StubFile.new if version == 'good'
      nil
    end
  end
end
