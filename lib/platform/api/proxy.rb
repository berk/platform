module Platform
  module Api
    module Proxy

      def self.add(klass, proxy_class)
        proxy_class.ensure_valid_class_name
        (Platform::Config.proxies[klass.name] ||= SortedSet.new) << proxy_class
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
        Platform::Config.proxies.clear
      end

    private

      def self.proxies_for(klass)
        Platform::Config.load_proxies if Platform::Config.proxies.empty?
        klass.ancestors.detect {|ii| return Platform::Config.proxies[ii.name] if Platform::Config.proxies.has_key?(ii.name)}
        return nil
      end

    end # module Proxy
  end # module Api
end # module Platform
