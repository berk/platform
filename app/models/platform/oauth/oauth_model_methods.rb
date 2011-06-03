module Platform::Oauth::OauthModelMethods

  def self.included(base)
    base.has_many :applications, :class_name => "Platform::Application", :dependent=>:destroy
    base.has_many :access_tokens, :class_name => "Platform::Oauth::AccessToken", :dependent => :destroy
    base.has_many :request_tokens, :class_name => "Platform::Oauth::RequestToken", :dependent => :destroy
  end

  def authorized_oauth_access_tokens
    self.access_tokens.select{|t| t.authorized_at}
  end

  def access_token_for(application)
    return unless application
    access_tokens.detect{|t| t.application_id == application.id}
  end

  def create_authorized_access_token(application)
    return unless application
    OauthRequestToken.create(:application => application, :user => self).try(:create_access_token)
  end

end
