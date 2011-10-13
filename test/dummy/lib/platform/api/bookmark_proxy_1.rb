module Api
  module Proxy
    class BookmarkProxy_1 < Platform::Api::Proxy::Base
      proxy_for(Bookmark)
      
      def to_api_hash(options={})
        {:id => instance.id, :title => instance.title, :url => instance.url, :created_at => instance.created_at.to_i, :path => to_api_path}
      end

    end # class BookmarkProxy_1
  end # module Proxy
end # module Api
