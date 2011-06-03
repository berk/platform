require 'oauth'
class Platform::Application < ActiveRecord::Base
  set_table_name :platform_applications
  
  # useful methods - should be public
  include Platform::SimpleStringPermissions

  belongs_to :developer, :class_name => "Platform::Developer"
  has_many :application_developers, :class_name => "Platform::ApplicationDeveloper"
  has_many :application_metrics, :class_name => "Platform::ApplicationMetric"
  
  has_many :tokens,           :class_name => "Platform::Oauth::OauthToken"
  has_many :access_tokens,    :class_name => "Platform::Oauth::AccessToken"
  has_many :oauth2_verifiers, :class_name => "Platform::Oauth::Oauth2Verifier"
  has_many :oauth_tokens,     :class_name => "Platform::Oauth::OauthToken"

  belongs_to :icon, :class_name => "Platform::Media::Image", :foreign_key => "icon_id", :dependent => :destroy
  belongs_to :logo, :class_name => "Platform::Media::Image", :foreign_key => "logo_id", :dependent => :destroy

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

  #19851 - Application directory flow
  acts_as_state_machine :initial => :new
  state :new
  state :submitted
  state :approved
  state :rejected 
  state :blocked 
  
  event :submit do
    transitions :from => :new, :to => :submitted
    transitions :from => :rejected, :to   => :submitted
  end
  
  event :block do
    transitions :from => :new, :to          => :blocked
    transitions :from => :submitted, :to    => :blocked
    transitions :from => :approved, :to     => :blocked
    transitions :from => :rejected, :to     => :blocked
  end

  event :approve do
    transitions :from => :submitted, :to    => :approved
  end

  event :reject do
    transitions :from => :submitted, :to    => :rejected
  end
  
  def self.find_token(token_key)
    token = OauthToken.find_by_token(token_key, :include => :client_application)
    if token && token.authorized?
      token
    else
      nil
    end
  end

  def self.verify_request(request, options = {}, &block)
    begin
      signature = OAuth::Signature.build(request, options, &block)
      return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      value = signature.verify
      value
    rescue OAuth::Signature::UnknownSignatureMethod => e
      false
    end
  end

  def last_token_for_user(user)
    OauthToken.find(:first, :conditions => ["client_application_id = ? and user_id = ?", self.id, user.id], :order => "updated_at desc")
  end

  def valid_tokens_for_user(user)
    OauthToken.find(:all, :conditions => ["client_application_id = ? and user_id = ? and invalidated_at is null", self.id, user.id])
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

  def oauth_server
    @oauth_server ||= OAuth::Server.new DEFAULT_SITE_LINK
  end

  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end

  # If your application requires passing in extra parameters handle it here
  def create_request_token(params={})
    RequestToken.create :client_application => self, :callback_url => token_callback_url || 'oob'
  end

  def admin_link
    "#{DEFAULT_SITE_LINK}/admin/applications/view/#{id}"
  end

  def self.permissions
    [:no_rate_limit, :grant_type_password, :unlimited_models, :add_without_premium]
  end
  
  def enable!
    update_attributes(:enabled => true)
  end

  def disable!
    update_attributes(:enabled => false)
  end
  
  def icon_url
    return "/platform/images/default_app_icon.gif" unless icon
    icon.media_url(:icon)
  end
  
  def store_icon(file)
    self.icon = Image.create
    self.icon.content_type = "image/gif"
    self.icon.write(file)
    self.icon.save
    self.save
  end

  def logo_url
    return "/platform/images/default_app_logo.gif" unless logo
    logo.media_url(:logo)
  end

  def store_logo(file)
    self.logo = Image.create
    self.logo.content_type = "image/gif"
    self.logo.write(file)
    self.logo.save
    self.save
  end
  
  def app_url
    return url if canvas_name.blank?      
    "http://#{SITE}/apps/#{canvas_name}"
  end
  
  def short_name
    return name if name.length < 15
    "#{name[0..15]}..."
  end
  
protected

  def generate_keys
    self.key = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end

  # Ticket 19680
  after_create :notify_admins
  def notify_admins
    return unless Registry.api.admin_email?
    message = "#{Platform::Config.current_user.profile.name} (#{Platform::Config.current_user.admin_link}) has created an app called #{name} (#{admin_link})."
    SystemNotifier.deliver_to_admin(message, :subject => 'Client Application Created', :to => Registry.api.admin_email)
  end

end
