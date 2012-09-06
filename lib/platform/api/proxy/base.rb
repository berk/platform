module Platform
  module Api
    module Proxy
      class Base

        # Find the proxy for class instance and version
        def self.proxy_class_for(instance, version=::Platform::Config.api_default_version)
          version = version.to_i
          while version >= 0
            proxy_path = "#{::Platform::Config.root}/#{::Platform::Config.api_proxies_path}/#{instance.class.name.underscore}_proxy_#{version}.rb"
            pp proxy_path

            unless File.exist?(proxy_path)
              version -= 1
              next
            end

            require_or_load proxy_path

            proxy_class_name = "::Platform::Api::Proxy::#{instance.class.name}Proxy_#{version}"
            begin
              klass = proxy_class_name.constantize
              return klass.new(instance)
            rescue NameError => er
              version -= 1
            end
          end

          raise "No API proxy class found for #{instance.class.name}"
        end

        attr_accessor :instance

        def initialize(instance)
          @instance = instance
        end

        def update_attributes!(attrs)
          instance.update_attributes!(attrs)
        end

        def to_api_json(opts={})
          Api::AlreadyJsonedString.new(to_api_hash(opts).to_json(opts))
        end

        def to_api_xml(opts={})
          opts = opts.dup
          opts[:root] ||= instance.class.name.underscore.downcase
          to_api_hash(opts).to_xml(opts)
        end

        def self.<=>(other)
          api_version <=> other.api_version
        end

        def self.api_version
          @api_version ||= begin
            $1.to_i if name =~ /_(\d+)$/
          end
        end

        def self.instance_class
          @klass
        end

        def to_api_hash(opts = {})
          raise NotImplementedError, 'Must be implemented in descendant class'
        end
        
        def to_api_path(opts = {})
          "#{::Platform::Config.api_scheme}://#{::Platform::Config.api_base_url}/#{instance.class.name.underscore}/#{instance.id}"
        end

        def full_url(url)
          return url if url.index('http')
          "http://#{::Platform::Config.site_base_url}#{url}"
        end

      end # class Base

    end # module Proxy
  end # module Api
end # module Platform
