module Api
  module Proxy
    class UserProxy_1 < Platform::Api::Proxy::Base
      proxy_for(User)

      def to_api_hash(options={})
        {:name => instance.name, :first_name => instance.first_name, :last_name => instance.last_name, :created_at => instance.created_at.to_i}
      end

    end # class UserProxy_1
  end # module Proxy
end # module Api
