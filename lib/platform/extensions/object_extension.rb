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

class Object
  
  # makes the object API enabled and overwrites to_json and to_xml methods
  def self.has_platform_api_proxy(opts = {})
    self.class_eval do
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
  
  def self.api_proxy(version=nil)
    Platform::Api::Proxy.proxy_class_for(self, version)
  end
  
end