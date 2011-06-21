class Platform::Oauth::RefreshToken < Platform::Oauth::OauthToken

  validates_presence_of :user

  def exchange!(params={})
    Platform::Oauth::OauthToken.transaction do
      token = Platform::Oauth::AccessToken.create!(:user => user, :application => application)
      invalidate!
      token
    end
  end

  def redirect_url
    callback_url
  end

  protected

  def generate_keys
    self.token = Platform::Helper.generate_key(20)[0,20]
  end

end
