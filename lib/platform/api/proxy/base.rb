require 'platform/api/proxy'

module Platform
  module Api
    module Proxy

      class Base

        attr_accessor :instance

        def self.proxy_for(klass)
          Proxy.add(klass, self)

          klass.class_eval do
            def self.api_proxy(version=nil)
              Platform::Api::Proxy.proxy_class_for(self, version)
            end

            def api_proxy(version=nil)
              Platform::Api::Proxy.for(self, version)
            end

            def to_json(opts={})
              api_proxy(opts[:api_version]).to_json(opts)
            end

            def to_xml(opts={})
              api_proxy(opts[:api_version]).to_xml(opts)
            end
            
            def to_api_hash(opts={})
              api_proxy(opts[:api_version]).to_api_hash(opts)
            end
          end
        end

        def initialize(instance)
          @instance = instance
        end

        def update_attributes!(attrs)
          instance.update_attributes!(attrs)
        end

        def to_json(options={})
          Api::AlreadyJsonedString.new(to_api_hash(options).to_json(options))
        end

        def to_xml(options={})
          options = options.dup
          options[:root] ||= instance.class.name.underscore.downcase
          to_api_hash(options).to_xml(options)
        end

        def self.<=>(other)
          api_version <=> other.api_version
        end

        def self.api_version
          @api_version ||= begin
            $1.to_i if name =~ /_(\d+)$/
          end
        end

        def self.ensure_valid_class_name
          raise NameError.new("Proxy class name (#{name}) must end in _<version>") if api_version.nil?
        end

        def to_api_hash(opts)
          raise NotImplementedError, 'Must be implemented in descendant class'
        end

      end # class Base

    end # module Proxy
  end # module Api
end # module Platform
