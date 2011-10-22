#--
# Copyright (c) 2010-2011 Michael Berkovich
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Platform
  module Generators
    class ProxyGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)
      class_option :version, :type => :string, :aliases => '-v', :desc => 'Version of the proxy to be generated.'
      class_option :attributes, :type => :string, :aliases => '-a', :desc => 'List of attributes to be generated.'
      class_option :class, :type => :string, :aliases => '-c', :desc => 'Name of the class for which the proxy is created. If left blank the template name will be used.'

      desc "Creates an API proxy file for your model"
      def create_proxy_file
        create_file "#{Platform::Config.api_proxies_path}/#{file_name}_proxy_#{version}.rb", %Q{
module Api
  module Proxy
    class #{class_name}Proxy_#{version} < Platform::Api::Proxy::Base
      proxy_for(#{proxy_class})

      def to_api_hash(options={})
        {#{attributes}}
      end

    end
  end
end
      }        
      end
      
    private
    
      def version
        options[:version] || '0'
      end

      def proxy_class_provided?
        return false if options[:class].blank?
        options[:class] != "class"
      end

      def proxy_class
        return class_name unless proxy_class_provided?
        options[:class]
      end
      
      def attributes
        if proxy_class_provided?
          klass = proxy_class.constantize
          return klass.attribute_names.collect{|attr| ":#{attr} => instance.#{attr}"}.join(", ")
        end
        
        return ":id => instance.id" if options[:attributes].blank? or options[:attributes] == "attributes"
        options[:attributes].split(",").collect{|attr| ":#{attr.strip} => instance.#{attr.strip}"}.join(", ")
      end
      
    end
  end
end