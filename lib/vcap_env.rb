require 'json'

# Parses ENV['VCAP_SERVICES'] or similar JSON and sets ENV variables for user-provided:credentials
module VcapEnv
  def self.set_env(vcap_json)
    vcap = JSON.parse(vcap_json)
    env = vcap["user-provided"].find { |service| service["name"] == "compliance-viewer-env"  }

    env["credentials"].each_pair do |name, value|
      ENV[name.upcase] = value
    end
  end
end
