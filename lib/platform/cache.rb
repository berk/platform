class Platform::Cache
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