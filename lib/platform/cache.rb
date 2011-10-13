#--
# Copyright (c) 2011 Michael Berkovich, Geni Inc
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
  class Cache
    def self.cache
      @cache ||= begin
        if Platform::Config.cache_adapter == 'ActiveSupport::Cache'
          store_params = [Platform::Config.cache_store].flatten
          store_params[0] = store_params[0].to_sym
          ActiveSupport::Cache.lookup_store(*store_params)
        else
          eval(Platform::Config.cache_adapter)  
        end
      end
    end
  
    def self.enabled?
      Platform::Config.enable_caching?
    end
  
    def self.versioned_key(key)
      "#{Platform::Config.cache_version}_#{key}"
    end
  
    def self.fetch(key, options = {})
      return yield unless enabled?
      cache.fetch(versioned_key(key), options) do 
        yield
      end
    end

    def self.delete(key, options = nil)
      return unless enabled?
      cache.delete(versioned_key(key), options)
    end

    def self.increment(key, amount = 1)
      return unless enabled?
      cache.increment(versioned_key(key), amount)
    end

    def self.decrement(key, amount = 1)
      return unless enabled?
      cache.decrement(versioned_key(key), amount)
    end
  
    def self.set(key, value, options = {})
      return unless enabled?
      cache.set(key, value, options)
    end
  
    def self.get(key, options = {})
      return unless enabled?
      cache.get(key, options)
    end
  end
end