require 'spec_helper'
require 'stub_classes'

describe ComplianceData do
  describe 'initialize' do
    it 'returns the right thing' do
      data = ComplianceData.new StubClasses::StubSettings
      expect(data).to be_an_instance_of ComplianceData
    end

    it 'raises an argument error if settings are not correct' do
      expect { ComplianceData.new nil }.to raise_error 'ArgumentError'
    end
  end

  describe 'base_name' do
    @data = nil

    before :each do
      @data = ComplianceData.new StubClasses::StubSettings
    end

    it 'does the right thing' do
      base = @data.base_name 'path/to/file.json'
      expect(base).to eq 'file'
    end

    it 'handles a missing extension' do
      base = @data.base_name 'path/to/file'
      expect(base).to eq 'file'
    end

    it 'handles a base name' do
      base = @data.base_name 'file'
      expect(base).to eq 'file'
    end

    it 'returns empty string if passed nil' do
      base = @data.base_name nil
      expect(base).to eq ''
    end
  end

  describe 'full_name' do
    @data = nil

    before :each do
      @data = ComplianceData.new StubClasses::StubSettings
    end

    it 'does the right thing' do
      full = @data.full_name 'file'
      expect(full).to eq 'results/file.json'
    end

    it 'returns an empty string if passed nil' do
      full = @data.full_name nil
      expect(full).to eq ''
    end
  end

  describe 'key_list' do
    @data = nil

    class StubObjectSummary
      attr_reader :key
      def initialize(key_value)
        @key = key_value
      end
    end

    before :each do
      @data = ComplianceData.new StubClasses::StubSettings
    end

    it 'does the right thing' do
      allow_any_instance_of(Aws::S3::Bucket).to receive(:objects)
        .and_return(
          [
            StubObjectSummary.new(
              "#{StubClasses::StubSettings.results_folder}/abc"),
            StubObjectSummary.new(
              "#{StubClasses::StubSettings.results_folder}/bcd")
          ])
      projects = @data.key_list
      expect(projects[0]).to eq 'abc'
      expect(projects[1]).to eq 'bcd'
    end

    it 'returns an empty list if no results returned from AWS' do
      allow_any_instance_of(Aws::S3::Bucket).to receive(:objects)
        .and_return(nil)
      projects = @data.key_list
      expect(projects).to eq []
    end
  end

  describe 'get_version_list' do
    @data = nil

    before :each do
      @data = ComplianceData.new StubClasses::StubSettings
    end

    it 'does the right thing' do
      allow_any_instance_of(Aws::S3::Bucket).to receive(:object_versions)
        .and_return(%w(abc bcd))
      projects = @data.get_version_list 'test'
      expect(projects[0]).to eq 'abc'
      expect(projects[1]).to eq 'bcd'
    end
  end

  describe 'get_file' do
    @data = nil

    before :each do
      @data = ComplianceData.new StubClasses::StubSettings
    end

    it 'does the right thing' do
      allow_any_instance_of(Aws::S3::Bucket).to receive(:object)
        .and_return(Aws::S3::Object.new(
                      bucket_name: StubClasses::StubSettings.aws_bucket,
                      key: 'abc'))
      allow_any_instance_of(Aws::S3::Object).to receive(:get)
        .and_return('abc')

      file = @data.get_file 'name', 'version'
      expect(file).to eq 'abc'
    end

    it 'does the right thing with no version' do
      allow_any_instance_of(Aws::S3::Bucket).to receive(:object)
        .and_return(Aws::S3::Object.new(
                      bucket_name: StubClasses::StubSettings.aws_bucket,
                      key: 'abc'))
      allow_any_instance_of(Aws::S3::Object).to receive(:get)
        .and_return('abc')

      file = @data.get_file 'name', nil
      expect(file).to eq 'abc'
    end
  end

  describe 'get_json' do
    @data = nil

    before :each do
      @data = ComplianceData.new StubClasses::StubSettings
    end

    it 'does the right thing' do
      file = StubClasses::StubFile.new('data' => 'abc')
      expect(@data.get_json(file)).to eq '{"data":"abc"}'
    end

    it 'returns nil if nil passed in' do
      expect(@data.get_json(nil)).to eq nil
    end
  end
end
