module Api
  module Proxy
    class PlatformApplicationProxy_0 < Platform::Api::Proxy::Base
      proxy_for(Platform::Application)

      def to_api_hash(options={})
        { 
          :id => instance.id,
          :developer => instance.developer.to_api_hash(options), 
          :name => instance.name, 
          :description => instance.description, 
          :locale => instance.locale, 
          :support_url => instance.support_url, 
          :contact_email => instance.contact_email, 
          :privacy_policy_url => instance.privacy_policy_url, 
          :terms_of_service_url => instance.terms_of_service_url, 
          :url => instance.url, 
          :icon_url => full_url(instance.icon_url), 
          :logo_url => full_url(instance.logo_url), 
          :canvas_url => instance.app_url, 
          :created_at => instance.created_at
          }
      end

    end
  end
end
      