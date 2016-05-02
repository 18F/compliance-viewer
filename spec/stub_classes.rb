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
    attr_reader :body, :last_modified
    def initialize(alerts = [])
      @body = StubBody.new(alerts)
      @last_modified = Time.now
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

  # Aws::Resources::Collection doesn't support .empty?. This object
  # helps us to model that limitation more closely.
  class StubCollection
    include Enumerable

    def initialize(items = [])
      @items = items
    end

    def each(&block)
      @items.each(&block)
    end
  end

end
