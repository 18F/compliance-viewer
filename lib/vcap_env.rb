require 'json'

# Parses ENV['VCAP_SERVICES'] or similar JSON and sets ENV variables for user-provided:credentials
module VcapEnv
  def self.set_env(vcap_json)
    vcap = JSON.parse(vcap_json)
    %w(s3 user-provided).each do |group|
      env = vcap[group].first
      env['credentials'].each_pair do |name, value|
        ENV[name.upcase] = value
      end
    end
  end
end
