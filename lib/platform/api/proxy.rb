module Platform
  module Api
    module Proxy

      @proxies = {}

      def self.add(klass, proxy_class)
        proxy_class.ensure_valid_class_name
        (@proxies[klass] ||= SortedSet.new) << proxy_class
      end

      def self.proxy_class_for(klass, version=nil)
        unless proxy_array = proxies_for(klass)
          raise ArgumentError, "No proxy for class: #{klass.name}"
        end

        proxy_array = proxy_array.to_a
        if version.nil?
          proxy_class = proxy_array.last
        else
          version = version.to_i
          proxy_class = proxy_array.reverse.find {|ii| ii.api_version <= version}
        end
        raise ArgumentError "No proxy for version: #{version}" if proxy_class.nil?

        proxy_class
      end

      def self.for(instance, version=nil)
        return proxy_class_for(instance.class, version).new(instance)
      end

      def self.reset
        @proxies.clear
      end

    private

      def self.proxies_for(klass)
        klass.ancestors.detect {|ii| return @proxies[ii] if @proxies.has_key?(ii)}
        return nil
      end

    end # module Proxy
  end # module Api
end # module Platform
