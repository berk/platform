class Platform::Application < ActiveRecord::Base
  set_table_name :platform_applications
  
  # useful methods - should be public
  include Platform::SimpleStringPermissions

  belongs_to :developer, :class_name => "Platform::Developer"
  has_many :application_developers, :class_name => "Platform::ApplicationDeveloper", :dependent => :destroy
  has_many :application_metrics, :class_name => "Platform::ApplicationMetric", :dependent => :destroy
  has_many :application_users, :class_name => "Platform::ApplicationUser", :dependent => :destroy
  has_many :application_logs, :class_name => "Platform::ApplicationLog", :dependent => :destroy
  
  has_many :tokens,           :class_name => "Platform::Oauth::OauthToken", :dependent => :destroy
  has_many :access_tokens,    :class_name => "Platform::Oauth::AccessToken", :dependent => :destroy
  has_many :verifier_tokens,  :class_name => "Platform::Oauth::VerifierToken", :dependent => :destroy

  belongs_to :icon, :class_name => "Platform::Media::Image", :foreign_key => "icon_id"
  belongs_to :logo, :class_name => "Platform::Media::Image", :foreign_key => "logo_id"

  validates_presence_of :name, :url, :key, :secret, :contact_email
  validates_uniqueness_of :key
  before_validation_on_create :generate_keys

  URL_REGEX = /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i
  validates_format_of :url,                   :with => URL_REGEX
  validates_format_of :support_url,           :with => URL_REGEX, :allow_blank=>true
  validates_format_of :callback_url,          :with => URL_REGEX, :allow_blank=>true
  validates_format_of :support_url,           :with => URL_REGEX, :allow_blank=>true
  validates_format_of :privacy_policy_url,    :with => URL_REGEX, :allow_blank=>true
  validates_format_of :terms_of_service_url,  :with => URL_REGEX, :allow_blank=>true
  validates_format_of :canvas_url,            :with => URL_REGEX, :allow_blank=>true

  attr_accessor :token_callback_url

  acts_as_state_machine :initial => :new
  state :new
  state :submitted
  state :approved
  state :rejected 
  state :blocked 
  
  event :submit do
    transitions :from => :new,        :to => :submitted
    transitions :from => :rejected,   :to => :submitted
  end
  
  event :block do
    transitions :from => :new,        :to => :blocked
    transitions :from => :submitted,  :to => :blocked
    transitions :from => :approved,   :to => :blocked
    transitions :from => :rejected,   :to => :blocked
  end

  event :unblock do
    transitions :from => :blocked,    :to => :new
  end

  event :approve do
    transitions :from => :new,        :to => :approved
    transitions :from => :submitted,  :to => :approved
  end

  event :reject do
    transitions :from => :submitted,  :to => :rejected
  end
  
  def self.find_token(token_key)
    token = Platform::Oauth::OauthToken.find_by_token(token_key, :include => :application)
    if token && token.authorized?
      token
    else
      nil
    end
  end

#  def self.verify_request(request, options = {}, &block)
#    begin
#      signature = ::OAuth::Signature.build(request, options, &block)
#      return false unless Platform::Oauth::OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
#      value = signature.verify
#      value
#    rescue ::OAuth::Signature::UnknownSignatureMethod => e
#      false
#    end
#  end

  def last_token_for_user(user)
    Platform::Oauth::OauthToken.find(:first, :conditions => ["application_id = ? and user_id = ?", self.id, user.id], :order => "updated_at desc")
  end

  def valid_tokens_for_user(user)
    Platform::Oauth::OauthToken.find(:all, :conditions => ["application_id = ? and user_id = ? and invalidated_at is null", self.id, user.id])
  end

  def rate_limited(value=true)
    set_permission(:no_rate_limit, !value)
  end

  def rate_limited!(value=true)
    rate_limited(value)
    save!
  end

  def rate_limited?
    ! has_permission?(:no_rate_limit)
  end

  # Ticket 19135
  def allow_grant_type_password(value=true)
    set_permission(:grant_type_password, value)
  end

  # Ticket 19135
  def allow_grant_type_password!(value=true)
    allow_grant_type_password(value)
    save!
  end

  # Ticket 19135
  def allow_grant_type_password?
    has_permission?(:grant_type_password)
  end

  # Ticket 19180
  def allow_unlimited_models(value=true)
    set_permission(:unlimited_models, value)
  end

  # Ticket 19180
  def allow_unlimited_models!(value=true)
    allow_unlimited_models(value)
    save!
  end

  # Ticket 19180
  def allow_unlimited_models?
    has_permission?(:unlimited_models)
  end

  # Ticket 19507
  def allow_add_without_premium(value=true)
    set_permission(:add_without_premium, value)
  end

  # Ticket 19507
  def allow_add_without_premium!(value=true)
    allow_add_without_premium(value)
    save!
  end

  # Ticket 19507
  def allow_add_without_premium?
    has_permission?(:add_without_premium)
  end

  # If your application requires passing in extra parameters handle it here
  def create_request_token(params={})
    Platform::Oauth::RequestToken.create(params.merge(:application => self))
  end

  def create_access_token(params={})
    Platform::Oauth::AccessToken.create(params.merge(:application => self))
  end

  def create_refresh_token(params={})
    Platform::Oauth::RefreshToken.create(params.merge(:application => self))
  end

  def admin_link
    "#{DEFAULT_SITE_LINK}/admin/applications/view/#{id}"
  end

  def self.permissions
    [:no_rate_limit, :grant_type_password, :unlimited_models, :add_without_premium]
  end
  
  def icon_url
    return "/platform/images/default_app_icon.gif" unless icon
    icon.url
  end
  
  def store_icon(file)
    self.icon = Platform::Media::Image.create
    self.icon.write(file, :size => 16)
    self.save
  end

  def logo_url
    return "/platform/images/default_app_logo.gif" unless logo
    logo.url
  end

  def store_logo(file)
    self.logo = Platform::Media::Image.create
    self.logo.write(file, :size => 75)
    self.save
  end
  
  def app_url
    return url if canvas_name.blank?      
    "http://#{SITE}/platform/apps/#{canvas_name}"
  end
  
  def short_name
    return name if name.length < 15
    "#{name[0..15]}..."
  end

  def self.featured_for_category(category, page = 1, per_page = 20)
    conditions = [" (state='approved') "]
    if category and category.keyword != 'all'
      conditions[0] << " and " unless conditions[0].blank?
      conditions = ["(id in (select item_id from category_items where category_id = ?))", category.id]
    end
    
    paginate(:conditions => conditions, :page => page, :per_page => per_page)
  end
  
  def self.for_category(category, page = 1, per_page = 20)
    conditions = [" (state='approved') "]
    if category and category.keyword != 'all'
      conditions[0] << " and " unless conditions[0].blank?
      conditions = ["(id in (select item_id from category_items where category_id = ?))", category.id]
    end
    
    paginate(:conditions => conditions, :page => page, :per_page => per_page)
  end
  
  def update_rank!
    total_rank = (rating_count == 0) ? 0 : (rating_sum/rating_count)
    self.update_attributes(:rank => total_rank)
    total_rank
  end
  
  def rating_count
    @rating_count ||= Platform::Rating.count(:id, :conditions => ["object_type = ? and object_id = ?", self.class.name, self.id])
  end

  def rating_sum
    @rating_sum ||= Platform::Rating.sum(:value, :conditions => ["object_type = ? and object_id = ?", self.class.name, self.id])
  end
  
  def reset_secret!
    update_attributes(:secret => Platform::Helper.generate_key(40)[0,40])
  end
  
protected

  def generate_keys
    self.key = Platform::Helper.generate_key(40)[0,40]
    self.secret = Platform::Helper.generate_key(40)[0,40]
  end

#  after_create :notify_admins
#  def notify_admins
#    return unless Registry.api.admin_email?
#    return unless Platform::Config.current_user
#    
#    message = "#{Platform::Config.current_user.name} (#{Platform::Config.current_user.admin_link}) has created an app called #{name} (#{admin_link})."
#    SystemNotifier.deliver_to_admin(message, :subject => 'Client Application Created', :to => Registry.api.admin_email)
#  end

end
