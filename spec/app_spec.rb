require 'spec_helper'
require 'rack/test'
require 'omniauth-myusa'
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
    it 'returns as expected with the index if authed' do
      ComplianceData.any_instance.stubs(:keys).returns(%w(abc bcd))
      get '/', {}, 'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      expect(last_response.body).to include('Projects')
      ComplianceData.any_instance.unstub(:keys)
    end

    it 'redirects to the auth page if unauthed' do
      get '/'
      expect(last_response.redirect?).to eq true
      expect(last_response['Location']).to include('/auth/myusa')
    end
  end

  describe '/results' do
    it "redirects to the home page" do
      get '/results', {}, 'rack.session' => { user_email: 'example@example.com' }
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
      get "/results/#{name}", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      expect(last_response.body).to include(name)
      ComplianceData.any_instance.unstub(:base_name)
      ComplianceData.any_instance.unstub(:versions)
    end

    it 'returns Invalid Project if passed a name that doesn\'t exist' do
      ComplianceData.any_instance.stubs(:versions).returns(
        StubClasses::StubCollection.new)
      get "/results/name", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      expect(last_response.body).to include('Invalid Project')
      ComplianceData.any_instance.unstub(:versions)
    end

    it 'redirects to the auth page if unauthed with a name' do
      get '/results/name'
      expect(last_response.redirect?).to eq true
      expect(last_response['Location']).to include('/auth/myusa')
    end

    it 'redirects to the auth page if unauthed without a name' do
      get '/results/'
      expect(last_response.redirect?).to eq true
      expect(last_response['Location']).to include('/auth/myusa')
    end
  end

  describe '/results/:name/:version' do
    it 'returns successfully if passed a name and version that exists' do
      ComplianceData.any_instance.stubs(:file_for).returns(
        StubClasses::StubFile.new)
      get "/results/good/good", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      ComplianceData.any_instance.unstub(:file_for)
    end

    it 'returns successfully in JSON' do
      ComplianceData.any_instance.stubs(:file_for).returns(
        StubClasses::StubFile.new)
      get "/results/good/good?format=json", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      ComplianceData.any_instance.unstub(:file_for)
    end

    it 'returns successfully if passed a name and current version' do
      ComplianceData.any_instance.stubs(:file_for).returns(
        StubClasses::StubFile.new)
      get "/results/good/current", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      ComplianceData.any_instance.unstub(:file_for)
    end

    it 'returns Invalid Version if passed a version that doesn\'t exist' do
      ComplianceData.any_instance.stubs(:file_for).returns nil
      get '/results/good/bad', {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      expect(last_response.body).to include('Invalid Version')
      ComplianceData.any_instance.unstub(:file_for)
    end

    it 'redirects to the auth page if unauthed' do
      get '/results/name/version'
      expect(last_response.redirect?).to eq true
      expect(last_response['Location']).to include('/auth/myusa')
    end
  end
end
