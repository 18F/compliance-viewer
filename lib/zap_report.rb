module ZapReport
  def self.create_report(file_data)
    return nil if file_data.nil?
    report_data = {}
    parsed_data = JSON.parse file_data.body.string
    report_data['summary'] = create_report_summary parsed_data
    report_data['alerts'] = create_report_alerts parsed_data
    report_data
  end

  def self.create_report_alerts(file_data)
    alerts = {}
    (file_data || []).each do |a|
      alert = a['alert']
      alerts[alert] = create_alert_record(a) unless alerts.key? alert
      alerts[alert]['instances'] = [] unless alerts[alert].key? 'instances'
      alerts[alert]['instances'].push create_alert_instance(a)
    end
    alerts
  end

  def self.create_alert_instance(alert_data)
    {
      'url' => alert_data['url'],
      'parameter' => alert_data['param'],
      'attack' => alert_data['attack'],
      'evidence' => alert_data['evidence']
    }
  end

  def self.create_alert_record(alert_data)
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

  def self.create_report_summary(file_data)
    levels = Hash.new 0
    (file_data || []).each { |a| levels[a['risk']] += 1 }
    levels
  end
end
