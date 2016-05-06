class ZapSummary
  LEVELS = %w(high medium low informational).freeze

  attr_reader :project_name, :data

  def initialize(project_name, data)
    @project_name = project_name
    @data = data
  end

  def top_level
    LEVELS.find { |level| data[level] > 0 }
  end

  def to_s
    if top_level
      num_alerts = data[top_level]
      "#{num_alerts} #{top_level} alerts"
    else
      "Scans passing"
    end
  end

  def self.from_s3_object(s3_object)
    name = File.basename(s3_object.key, '.json')
    data = JSON.load(s3_object.get.body)
    new(name, data)
  end
end
