require 'cfenv'

class NewRelicCredentials
  def self.license_key
      Cfenv.service('user-provided').credentials.new_relic_license_key
  end
end
