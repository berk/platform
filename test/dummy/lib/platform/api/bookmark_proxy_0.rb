module Api
  module Proxy
    class BookmarkProxy_0 < Platform::Api::Proxy::Base
      proxy_for(Bookmark)
      
      def to_api_hash(options={})
        {:title => instance.title, :url => instance.url, :created_at => instance.created_at.to_s}
      end

    end # class BookmarkProxy_0
  end # module Proxy
end # module Api
