class Platform::Oauth::AccessToken < Platform::Oauth::OauthToken
  validates_presence_of :user_id, :secret
  before_create :set_authorized_at
  
  # Implement this to return a hash or array of the capabilities the access token has
  # This is particularly useful if you have implemented user defined permissions.
  # def capabilities
  #   {:invalidate=>"/oauth/invalidate",:capabilities=>"/oauth/capabilities"}
  # end

  def to_json(options={})
    hash = {:access_token => token}
    hash[:expires_in] = valid_to.to_i - Time.now.to_i
    hash.to_json(options)
  end

protected

  def set_authorized_at
    self.authorized_at = Time.now
  end

  # Ticket 19802
  before_create :set_valid_to
  def set_valid_to
    self.valid_to ||= Time.now + lifetime
  end

  def lifetime
    @lifetime ||= eval Registry.api.token_lifetime
  end

end
