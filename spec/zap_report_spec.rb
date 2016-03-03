require 'spec_helper'

describe ZapReport do
  def alert_record
    {
      'confidence' => 'Medium',
      'wascid' => '0',
      'risk' => 'Low',
      'reference' => '',
      'url' => 'https://example.gov/faq',
      'solution' => 'Ensure JavaScript source files ...',
      'param' => 'param',
      'evidence' => 'evidence',
      'attack' => '',
      'other' => '',
      'messageId' => '53',
      'cweid' => '0',
      'alert' => 'Cross-Domain JavaScript ...',
      'id' => '30',
      'description' => 'The page at the following URL ...'
    }
  end

  describe 'create_report' do
    it 'returns the right thing' do
      expect(false).to eq true
    end
  end

  describe 'create_report_alerts' do
    it 'creates separate alerts for distinct alerts' do
      alert_record2 = alert_record.clone
      alert_record2['alert'] = 'abc'
      alerts = [alert_record, alert_record2]
      alert_report = ZapReport.create_report_alerts alerts
      expect(alert_report.length).to eq 2
      expect(alert_report[alert_record['alert']]['instances'].length).to eq 1
      expect(alert_report[alert_record2['alert']]['instances'].length).to eq 1
    end

    it 'does not duplicate alerts, creates separate instances' do
      alert_record2 = alert_record.clone
      alerts = [alert_record, alert_record2]
      alert_report = ZapReport.create_report_alerts alerts
      expect(alert_report.length).to eq 1
      expect(alert_report[alert_record['alert']]['instances'].length).to eq 2
    end

    it 'works with nil' do
      alert_report = ZapReport.create_report_alerts nil 
      expect(alert_report.length).to eq 0
    end
  end

  describe 'create_alert_instance' do
    it 'returns an object containing the correct fields' do
      trimmed_alert = ZapReport.create_alert_instance alert_record
      %w(url attack evidence).each do |val|
        expect(trimmed_alert[val]).to eq alert_record[val]
      end
      expect(trimmed_alert['parameter']).to eq alert_record['param']
      %w(risk confidence solution other).each do |val|
        expect(trimmed_alert[val]).to eq nil
      end
    end
  end

  describe 'create_alert_record' do
    it 'returns the right fields' do
      trimmed_alert = ZapReport.create_alert_record alert_record
      ['risk', 'confidence', 'description', 'solution', 'other',
       'reference', 'cweid', 'wascid'].each do |val|
        expect(trimmed_alert[val]).to eq alert_record[val]
      end
      %w(messageId id).each do |val|
        expect(trimmed_alert[val]).to eq nil
      end
    end
  end

  describe 'create_report_summary' do
    it 'returns appropriate counts' do
      alert_data = [
        { 'risk' => 'Low' },
        { 'risk' => 'Low' },
        { 'risk' => 'Medium' },
        { 'risk' => 'Low' }
      ]
      levels = ZapReport.create_report_summary alert_data
      expect(levels['Low']).to eq 3
      expect(levels['Medium']).to eq 1
      expect(levels['High']).to eq 0
    end

    it 'returns appropriate counts when nil passed in' do
      levels = ZapReport.create_report_summary nil
      expect(levels['Low']).to eq 0
      expect(levels['Medium']).to eq 0
    end

    it 'returns appropriate counts when an empty array passed in' do
      levels = ZapReport.create_report_summary []
      expect(levels['Low']).to eq 0
      expect(levels['Medium']).to eq 0
    end
  end
end
