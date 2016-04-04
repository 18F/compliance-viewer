require 'spec_helper'
require_relative '../lib/vcap_env'

describe VcapEnv do
  def vcap_json
    %(
    {
      "user-provided": [
        {
          "name": "compliance-viewer-env",
          "label": "user-provided",
          "credentials": {
            "app_id": "11235813",
            "app_secret": "*lips=zipped*",
            "aws_access_key": "123/abc+456&def",
            "aws_bucket": "cloud.gov-bucket-names/are+long",
            "aws_region": "us-east-1",
            "aws_secret_key": "shhhhhhhhhhhhh",
            "cookie_secret": "don'toverbakethem",
            "results_folder": "results",
            "results_format": ".json"
          }
        }
      ]
    }
    )
  end

  describe 'test_vcap_json' do
    it 'can be parsed' do
      expect JSON.parse(vcap_json)
    end
  end

  describe 'set_env' do
    it 'should have an empty ENV when this test starts' do
      expect(ENV['APP_ID']).to be nil
      expect(ENV['AWS_REGION']).to be nil
    end

    it 'parses VCAP_ENV JSON and sets ENV with values' do
      VcapEnv.set_env(vcap_json)
      expect(ENV['APP_ID']).to eq "11235813"
      expect(ENV['AWS_REGION']).to eq "us-east-1"
      expect(ENV['AWS_ACCESS_KEY']).to eq "123/abc+456&def"
      expect(ENV['COOKIE_SECRET']).to eq "don'toverbakethem"
      expect(ENV['RESULTS_FORMAT']).to eq ".json"
    end
  end

end
