module Api
  module Proxy
    class PlatformDeveloperProxy_0 < Platform::Api::Proxy::Base
      proxy_for(Platform::Developer)

      def to_api_hash(options={})
        {
          :id => instance.id, 
          :name => instance.name, 
          :about => instance.about || "", 
          :url => instance.url || "", 
          :created_at => instance.created_at
        }
      end

    end
  end
end
      