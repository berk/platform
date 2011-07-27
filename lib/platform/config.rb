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

class Platform::Config

  def self.init(site_current_user, current_application = nil)
    Thread.current[:platform_current_user] = site_current_user
    Thread.current[:platform_current_developer] = Platform::Developer.for(site_current_user)
    Thread.current[:platform_current_application] = current_application
  end

  def self.current_user
    Thread.current[:platform_current_user]
  end

  def self.current_developer
    Thread.current[:platform_current_developer] 
  end

  def self.current_application
    Thread.current[:platform_current_application]
  end

  def self.current_application=(app)
    Thread.current[:platform_current_application] = app
  end

  def self.current_user_is_developer?
    Thread.current[:platform_current_developer] != nil
  end

  def self.reset!
    Thread.current[:platform_current_user] = nil
    Thread.current[:platform_current_developer] = nil
    Thread.current[:platform_current_application] = nil
  end

  def self.models
    @models ||= begin 
      mdls = [
          Platform::ApplicationDeveloper, Platform::ApplicationPermission, Platform::ApplicationUser,
          Platform::ApplicationCategory, Platform::Category, 
          Platform::ForumMessage, Platform::ForumTopic,
          Platform::Permission, Platform::Rating,
          Platform::Developer, Platform::Application, 
          Platform::Oauth::OauthToken, Platform::Oauth::AccessToken, 
          Platform::Oauth::RequestToken, Platform::Oauth::RefreshToken,
          Platform::Media::Media, Platform::Media::Image,
          Platform::ApplicationLog, Platform::RollupLog, 
          Platform::ApplicationMetric, Platform::DailyApplicationMetric, 
          Platform::WeeklyApplicationMetric, Platform::MonthlyApplicationMetric, 
          Platform::TotalApplicationMetric, Platform::ApplicationUsageMetric,
          Platform::LoggedException
      ]
      
      if user_class_name == "Platform::PlatformUser" # used for stand-alone deployment only
        mdls << [Platform::PlatformUser, Platform::PlatformAdmin] 
      end  
      
      mdls.flatten
    end
  end
  
  def self.reset_all!
    models.each do |cls|
      puts ">> Resetting #{cls.name}..."
      cls.delete_all
    end

    init_default_categories
    init_default_applications

    puts "Done."
  end
  
  def self.system_user
    if user_class_name == "Platform::PlatformUser"
      @system_user ||= Platform::PlatformUser.first || Platform::PlatformUser.create(:name => "System User")
      return @system_user
    end
    
    return nil unless site_info[:system_user_id]
    @system_user ||= user_class_name.constantize.find_by_id(site_info[:system_user_id])
  end

  def self.system_developer
    @system_developer ||= Platform::Developer.find_or_create(Platform::Config.system_user)
  end

  def self.init_default_applications
    puts "Initializing default applications..."
    unless system_developer
      puts "Cannot initialize default application because system user id is not specified in the config."
      return
    end
  
    default_applications.each do |keyword, description|
      category_keywords = description.delete("category_keywords")
      icon_path = description.delete("icon_path")
      logo_path = description.delete("logo_path")

      app = Platform::Application.create(description.merge(:developer => system_developer))
      app.store_icon(File.new("#{root}/#{icon_path}", "r")) if icon_path 
      app.store_logo(File.new("#{root}/#{logo_path}", "r")) if logo_path 
      
      puts "Initialized #{app.name}."
      app.approve!
    end    
  end

  def self.init_default_categories
    puts "Initializing default categories..."
    init_categories(Platform::Category.root, default_categories)
  end

  def self.init_categories(parent, categories) 
    categories.each do |keyword, info|
      cat = Platform::Category.create(:parent => parent, :keyword => keyword, :name => info[:name], :position => info[:position])
      init_categories(cat, info[:categories]) if info[:categories]
    end
  end

  def self.default_applications
    @default_applications ||= load_yml("/config/platform/data/default_applications.yml")
  end

  def self.default_categories
    @default_categories ||= load_yml("/config/platform/data/default_categories.yml")
  end

  def self.root
    Rails.root
  end
  
  def self.env
    Rails.env
  end

  def self.load_yml(file_path, for_env = env)
    yml = YAML.load_file("#{root}#{file_path}")
    yml = yml[for_env] unless for_env.nil?
    HashWithIndifferentAccess.new(yml)
  end

  def self.config
    @config ||= load_yml("/config/platform/config.yml")
  end

  def self.enabled?
    config[:enable_platform] 
  end

  def self.disabled?
    not enabled?
  end

  def self.enable_app_directory?
    config[:enable_app_directory]
  end

  def self.enable_embedded_applications?
    config[:enable_embedded_applications]
  end

  def self.enable_mobile_applications?
    config[:enable_mobile_applications]
  end

  def self.enable_developer_agreement?
    config[:enable_developer_agreement]
  end

  def self.enable_app_statistics?
    config[:enable_app_statistics]
  end

  def self.enable_api_verification?
    config[:enable_api_verification]
  end

  def self.default_app_icon
    "/platform/images/default_app_icon.gif"
  end
  
  def self.default_app_logo
    "/platform/images/default_app_logo.gif"
  end  
  
  #########################################################
  # Config Sections
  #########################################################
  def self.caching
    config[:caching]
  end

  def self.logger
    config[:logger]
  end
  
  def self.site_info
    config[:site_info]
  end

  def self.api
    config[:API]
  end
  #########################################################

  #########################################################
  # Caching
  #########################################################
  def self.enable_caching?
    caching[:enabled]
  end

  def self.cache_adapter
    caching[:adapter]
  end

  def self.cache_store
    caching[:store]
  end

  def self.cache_version
    caching[:version]
  end
  #########################################################

  #########################################################
  # Logger
  #########################################################
  def self.enable_logger?
    logger[:enabled]
  end

  def self.log_path
    logger[:log_path]
  end
  #########################################################

  #########################################################
  # Site Info
  def self.site_title
    site_info[:title] 
  end
  
  def self.default_url
    site_info[:default_url]
  end

  def self.site_layout
    site_info[:platform_layout]
  end

  def self.admin_layout
    site_info[:admin_layout]
  end

  def self.media_directory
    site_info[:media_directory]
  end

  def self.media_path
    "#{root}/public#{media_directory}"
  end

  def self.helpers
    return [] unless site_info[:helpers]
    @tr8n_helpers ||= site_info[:helpers].collect{|helper| helper.to_sym}
  end

  def self.admin_helpers
    return [] unless site_info[:admin_helpers]
    @admin_helpers ||= site_info[:admin_helpers].collect{|helper| helper.to_sym}
  end
  
  def self.skip_before_filters
    return [] unless site_info[:skip_before_filters]
    @skip_before_filters ||= site_info[:skip_before_filters].collect{|filter| filter.to_sym}
  end

  def self.before_filters
    return [] unless site_info[:before_filters]
    @before_filters ||= site_info[:before_filters].collect{|filter| filter.to_sym}
  end

  def self.after_filters
    return [] unless site_info[:after_filters]
    @after_filters ||= site_info[:after_filters].collect{|filter| filter.to_sym}
  end

  #########################################################
  # site user info
  # The following methods could be overloaded in the initializer
  #########################################################
  def self.site_user_info
    site_info[:user_info]
  end

  def self.current_user_method
    site_user_info[:current_user_method]
  end

  def self.logout_method
    site_user_info[:logout_method]
  end

  def self.login_url
    site_info[:login_url]
  end

  def self.site_user_info_enabled?
    site_user_info[:enabled].nil? ? true : site_user_info[:enabled]
  end

  def self.site_user_info_disabled?
    !site_user_info_enabled?
  end
  
  def self.user_class_name
    return site_user_info[:class_name] if site_user_info_enabled?
    "Platform::PlatformUser"  
  end

  def self.user_class
    user_class_name.constantize
  end

  def self.user_id(user = current_user)
    begin
      user.send(site_user_info[:methods][:id])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch user id: #{ex.to_s}")
      return 0
    end  
  end

  def self.user_name(user = current_user)
    begin
      user.send(site_user_info[:methods][:name])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} name: #{ex.to_s}")
      return "Unknown user"
    end  
  end

  def self.user_email(user = current_user)
    begin
      user.send(site_user_info[:methods][:email])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} name: #{ex.to_s}")
      return nil
    end  
  end

  def self.user_gender(user = current_user)
    begin
      user.send(site_user_info[:methods][:gender])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} name: #{ex.to_s}")
      return "unknown"
    end  
  end

  def self.user_mugshot(user = current_user)
    begin
      mugshot_image = user.send(site_user_info[:methods][:mugshot])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} image: #{ex.to_s}")
    end  
    
    mugshot_image || silhouette_image(user)
  end

  def self.user_link(user = current_user)
    begin
      user.send(site_user_info[:methods][:link])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} link: #{ex.to_s}")
      return "/tr8n"
    end  
  end

  def self.user_locale(user = current_user)
    begin
      user.send(site_user_info[:methods][:locale])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} locale: #{ex.to_s}")
      return default_locale
    end  
  end

  def self.admin_user?(user = current_user)
    begin
      user.send(site_user_info[:methods][:admin])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} admin flag: #{ex.to_s}")
      return false
    end  
  end

  def self.current_user_is_admin?
    admin_user?
  end
  
  def self.guest_user?(user = current_user)
    return true unless user
    begin
      user.send(site_user_info[:methods][:guest])
    rescue Exception => ex
      Platform::Logger.error("Failed to fetch #{user_class_name} guest flag: #{ex.to_s}")
      return true
    end  
  end
  
  def self.current_user_is_guest?
    guest_user?
  end
  #########################################################

  #########################################################
  # Application Directory
  #########################################################
  def self.featured_apps_enabled?
    true
  end

  def self.featured_apps_title
    "Featured Applications"
  end

  def self.featured_apps_per_row
    2
  end

  def self.featured_apps_per_page
    2
  end

  def self.suggested_apps_title
    "Applications You May Like"
  end

  def self.suggested_apps_per_row
    5
  end

  def self.suggested_apps_per_page
    20
  end

  def self.searched_apps_title
    "Search Results"
  end

  def self.searched_apps_per_page
    15
  end
  
  #########################################################
  # API
  #########################################################
  def self.enable_api?
    api[:enabled]
  end

  def self.enable_api_log?
    api[:logging_enabled]
  end
  
  def self.api_request_limit
    api[:request_limit]
  end
  
  def self.api_request_window
    api[:request_window]
  end
  
  def self.api_cookies_enabled?
    api[:cookies_enabled]
  end

  def self.enable_public_api?
    api[:public_enabled]
  end

  def self.api_max_models
    api[:max_models]
  end
  
  def self.api_base_url
    api[:base_url]
  end  

  def self.api_supported_versions
    api[:supported_versions]
  end  

  def self.api_supported_version_options
    @api_supported_version_options ||= api[:supported_versions].collect{|v| ["v #{v}", v]}
  end  
  
  def self.api_default_version
    api[:default_version]
  end
  
  #########################################################
  # API References
  #########################################################
  
  def self.api_reference(api_version = api_default_version)
    @api_reference ||= begin
      ref = HashWithIndifferentAccess.new
      api_supported_versions.each do |version|
        ref[version] = {}
        path = "#{root}/#{api[:config_path]}/#{version}"
        files = Dir.glob("#{path}/*.yml")
        files.each do |file|
          ref[version].merge!(YAML.load_file(file))
        end
      end  
      ref.freeze
    end
    @api_reference[api_version]
  end

  def self.api_explorer_groups(api_version = api_default_version)
    api[:explorer_groups][api_version]
  end
  
  #########################################################

  def self.silhouette_image(user = current_user)
    "/platform/images/photo_silhouette.gif"
  end

  def self.features
    @features ||= begin
      defs = load_yml("/config/platform/site/features.yml")
      feats = []
      defs[:enabled_features].each do |key|
        defs[key][:key] = key
        feats << defs[key] 
      end
      feats
    end
  end

end
