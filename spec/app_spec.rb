require 'spec_helper'
require 'rack/test'
require 'stub_classes'

describe 'ComplianceViewer' do
  include Rack::Test::Methods

  before(:all) do
    set_test_env
  end

  after(:all) do
    unset_test_env
  end

  def app
    # "new!" is intentional (and ugly). Sinatra redefines new to include
    # the Rack middleware. Before doing that, it aliases the existing
    # functionality to new!. I do that so I can get access an actual
    # ComplianceViewer instance.
    ComplianceViewer.new!
  end

  describe '/' do
    it "renders the index" do
      ComplianceData.any_instance.stubs(:keys).returns(%w(abc bcd))
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Projects')
      ComplianceData.any_instance.unstub(:keys)
    end
  end

  describe '/results' do
    it "redirects to the home page" do
      get '/results'
      expect(last_response.redirect?).to eq true
      expect(last_response['Location']).to eq('http://example.org/')
    end
  end

  describe '/results/:name' do
    it 'returns successfully if passed a name that exists' do
      name = 'good'
      ComplianceData.any_instance.stubs(:base_name).returns(name)
      ComplianceData.any_instance.stubs(:versions).returns(
        StubClasses::StubCollection.new([
          StubClasses::StubObjectVersion.new(name),
          StubClasses::StubObjectVersion.new(name),
          StubClasses::StubObjectVersion.new(name)
        ])
      )
      get "/results/#{name}"
      expect(last_response).to be_ok
      expect(last_response.body).to include(name)
      ComplianceData.any_instance.unstub(:base_name)
      ComplianceData.any_instance.unstub(:versions)
    end

    it 'returns Invalid Project if passed a name that doesn\'t exist' do
      ComplianceData.any_instance.stubs(:versions).returns(
        StubClasses::StubCollection.new)
      get "/results/name"
      expect(last_response).to be_ok
      expect(last_response.body).to include('Invalid Project')
      ComplianceData.any_instance.unstub(:versions)
    end
  end

  describe '/results/:name/:version' do
    it 'returns successfully if passed a name and version that exists' do
      ComplianceData.any_instance.stubs(:file_for).returns(
        StubClasses::StubFile.new)
      get "/results/good/good"
      expect(last_response).to be_ok
      ComplianceData.any_instance.unstub(:file_for)
    end

    it 'returns successfully in JSON' do
      ComplianceData.any_instance.stubs(:file_for).returns(
        StubClasses::StubFile.new)
      get "/results/good/good?format=json"
      expect(last_response).to be_ok
      ComplianceData.any_instance.unstub(:file_for)
    end

    it 'returns successfully if passed a name and current version' do
      ComplianceData.any_instance.stubs(:file_for).returns(
        StubClasses::StubFile.new)
      get "/results/good/current"
      expect(last_response).to be_ok
      ComplianceData.any_instance.unstub(:file_for)
    end

    it 'returns Invalid Version if passed a version that doesn\'t exist' do
      ComplianceData.any_instance.stubs(:file_for).returns nil
      get '/results/good/bad'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Invalid Version')
      ComplianceData.any_instance.unstub(:file_for)
    end
  end
end
