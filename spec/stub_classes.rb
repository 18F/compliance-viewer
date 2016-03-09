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
      'bucket'
    end

    def self.results_format
      '.json'
    end

    def self.results_folder
      'results'
    end
  end
end
