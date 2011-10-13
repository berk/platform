module Api
  module Proxy
    class UserProxy_0 < Platform::Api::Proxy::Base
      proxy_for(User)
      
      def to_api_hash(options={})
        {:name => instance.name, :created_at => instance.created_at.to_s}
      end

    end # class UserProxy_0
  end # module Proxy
end # module Api
