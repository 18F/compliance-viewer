require 'spec_helper'
require 'rack/test'
require 'omniauth-myusa'
require 'stub_classes'

describe 'ComplianceViewer' do
  include Rack::Test::Methods

  def app
    ComplianceViewer.new! StubClasses::ComplianceDataStub.new
  end

  describe '/' do
    it 'returns as expected with the index if authed' do
      get '/', {}, 'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      expect(last_response.body).to include('Projects')
    end

    it 'redirects to the auth page if unauthed' do
      get '/'
      expect(last_response.redirect?).to eq true
      expect(last_response['Location']).to include('/auth/myusa')
    end
  end

  describe '/results' do
    it 'returns as expected with the index if authed' do
      get '/results', {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      expect(last_response.body).to include('Projects')
    end

    it 'redirects to the auth page if unauthed' do
      get '/results'
      expect(last_response.redirect?).to eq true
      expect(last_response['Location']).to include('/auth/myusa')
    end
  end

  describe '/results/:name' do
    it 'returns successfully if passed a name that exists' do
      name = 'good'
      get "/results/#{name}", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      expect(last_response.body).to include(name)
    end

    it 'returns Invalid Project if passed a name that doesn\'t exist' do
      name = 'bad'
      get "/results/#{name}", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      expect(last_response.body).to include('Invalid Project')
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
      name = 'good'
      version = 'good'
      get "/results/#{name}/#{version}", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
    end

    it 'returns successfully if passed a name and current version' do
      name = 'good'
      version = 'current'
      get "/results/#{name}/#{version}", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
    end

    it 'returns Invalid Version if passed a version that doesn\'t exist' do
      name = 'good'
      version = 'bad'
      get "/results/#{name}/#{version}", {},
          'rack.session' => { user_email: 'example@example.com' }
      expect(last_response).to be_ok
      expect(last_response.body).to include('Invalid Version')
    end

    it 'redirects to the auth page if unauthed' do
      get '/results/name/version'
      expect(last_response.redirect?).to eq true
      expect(last_response['Location']).to include('/auth/myusa')
    end
  end
end
