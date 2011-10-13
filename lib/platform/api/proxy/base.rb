require 'platform/api/proxy'

module Platform
  module Api
    module Proxy
      class Base

        attr_accessor :instance

        def self.proxy_for(klass)
          Proxy.add(klass, self)
        end
          
        def initialize(instance)
          @instance = instance
        end

        def update_attributes!(attrs)
          instance.update_attributes!(attrs)
        end

        def to_json(opts={})
          Api::AlreadyJsonedString.new(to_api_hash(opts).to_json(opts))
        end

        def to_xml(opts={})
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

        def self.ensure_valid_class_name
          raise NameError.new("Proxy class name (#{name}) must end in _<version>") if api_version.nil?
        end

        def to_api_hash(opts = {})
          raise NotImplementedError, 'Must be implemented in descendant class'
        end

        def to_api_path(opts = {})
          "#{Platform::Config.api_scheme}://#{Platform::Config.api_base_url}/#{instance.class.name.underscore}/#{instance.id}"
        end

      end # class Base

    end # module Proxy
  end # module Api
end # module Platform
