require 'openssl'
require 'base64'

module Platform::Helper 
  def self.generate_key(size=32)
    Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
  end
end    