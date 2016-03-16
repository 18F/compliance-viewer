require 'spec_helper'
require 'stub_classes'

describe ComplianceData do
  describe '#initialize' do
    it 'returns a correctly constructed ComplianceData' do
      data = ComplianceData.new StubClasses::StubSettings
      expect(data).to be_an_instance_of ComplianceData
      expect(data.bucket.name).to eq StubClasses::StubSettings.aws_bucket 
      expect(data.settings).to eq StubClasses::StubSettings
    end

    it 'raises an argument error if settings are not correct' do
      expect { ComplianceData.new nil }.to raise_error 'ArgumentError'
    end
  end

  describe '#base_name' do
    @data = nil

    it 'returns correct output if given good input' do
      @data = ComplianceData.new StubClasses::StubSettings
      base = @data.base_name 'path/to/file.json'
      expect(base).to eq 'file'
    end

    it 'handles a missing extension' do
      @data = ComplianceData.new StubClasses::StubSettings
      base = @data.base_name 'path/to/file'
      expect(base).to eq 'file'
    end

    it 'handles a base name' do
      @data = ComplianceData.new StubClasses::StubSettings
      base = @data.base_name 'file'
      expect(base).to eq 'file'
    end

    it 'returns empty string if passed nil' do
      @data = ComplianceData.new StubClasses::StubSettings
      base = @data.base_name nil
      expect(base).to eq ''
    end
  end

  describe '#full_name' do
    @data = nil

    it 'returns correct output if given good input' do
      @data = ComplianceData.new StubClasses::StubSettings
      full = @data.full_name 'file'
      expect(full).to eq 'results/file.json'
    end

    it 'returns an empty string if passed nil' do
      @data = ComplianceData.new StubClasses::StubSettings
      full = @data.full_name nil
      expect(full).to eq ''
    end
  end

  describe '#keys' do
    @data = nil

    class StubObjectSummary
      attr_reader :key
      def initialize(key_value)
        @key = key_value
      end
    end

    it 'retrieves correct output if given good input' do
      @data = ComplianceData.new StubClasses::StubSettings
      allow_any_instance_of(Aws::S3::Bucket).to receive(:objects)
        .and_return(
          [
            StubObjectSummary.new(
              "#{StubClasses::StubSettings.results_folder}/abc"),
            StubObjectSummary.new(
              "#{StubClasses::StubSettings.results_folder}/bcd")
          ])
      projects = @data.keys
      expect(projects[0]).to eq 'abc'
      expect(projects[1]).to eq 'bcd'
    end

    it 'returns an empty list if no results returned from AWS' do
      @data = ComplianceData.new StubClasses::StubSettings
      allow_any_instance_of(Aws::S3::Bucket).to receive(:objects)
        .and_return(nil)
      projects = @data.keys
      expect(projects).to eq []
    end
  end

  describe '#versions' do
    @data = nil

    it 'retrieves the correct output, if given good input' do
      @data = ComplianceData.new StubClasses::StubSettings
      allow_any_instance_of(Aws::S3::Bucket).to receive(:object_versions)
        .and_return(%w(abc bcd))
      projects = @data.versions 'test'
      expect(projects).to eq %w(abc bcd)
    end
  end

  describe '#file_for' do
    @data = nil

    it 'retrieves the correct output, if given the correct input' do
      @data = ComplianceData.new StubClasses::StubSettings
      allow_any_instance_of(Aws::S3::Bucket).to receive(:object)
        .and_return(Aws::S3::Object.new(
                      bucket_name: StubClasses::StubSettings.aws_bucket,
                      key: 'abc'))
      allow_any_instance_of(Aws::S3::Object).to receive(:get)
        .and_return('abc')

      file = @data.file_for 'name', 'version'
      expect(file).to eq 'abc'
    end

    it 'retrieves expected info if given correct input with no version' do
      @data = ComplianceData.new StubClasses::StubSettings
      allow_any_instance_of(Aws::S3::Bucket).to receive(:object)
        .and_return(Aws::S3::Object.new(
                      bucket_name: StubClasses::StubSettings.aws_bucket,
                      key: 'abc'))
      allow_any_instance_of(Aws::S3::Object).to receive(:get)
        .and_return('abc')

      file = @data.file_for 'name', nil
      expect(file).to eq 'abc'
    end
  end

  describe '#json_for' do
    @data = nil

    it 'retrieves the expected json if given good input' do
      @data = ComplianceData.new StubClasses::StubSettings
      file = StubClasses::StubFile.new('data' => 'abc')
      expect(@data.json_for(file)).to eq '{"data":"abc"}'
    end

    it 'returns nil if nil passed in' do
      @data = ComplianceData.new StubClasses::StubSettings
      expect(@data.json_for(nil)).to eq nil
    end
  end
end
