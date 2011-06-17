class Platform::OauthControllerTest < ActionController::TestCase

  before(:all) do
    @profile = create_claimed_profile(:primary_email => 'me@notgeni.com')
    @app = @profile.user.client_applications.create!(:name => 'test', :url => 'http://localhost/', :callback_url => 'http://localhost/', :contact_email => 'foo@notgeni.com')
  end

  # DEPRECATED
  xtest 'request_token' do
    set_oauth1_headers(@app)
    get :request_token
    assert_response :success

    hash = parse_response
    assert_equal hash[:oauth_token_secret], RequestToken.find_by_token(hash[:oauth_token]).secret, 'RequestToken not created'
  end

  test 'authorize requires login' do
    get :authorize
    assert_redirected_to '/login'
  end

  # Ticket 18822
  test 'authorize gracefully fails if no client app' do
    login_as @profile
    get :authorize, :client_id => 'invalid', :redirect_uri => 'http://foo.com/callback'
    assert_response :success
    assert_match 'no longer has access', @response.body
  end

  test 'get authorize' do
    login_as @profile
    token = @app.create_request_token

    get :authorize, :oauth_token => token.token
    assert_response :success

    assert_equal 'layouts/application', @response.layout  # Ticket 19364
    assert_select "input[name=oauth_token][value=#{token.token}]"
  end

  # Ticket 19364
  test 'authorize for iPhone' do
    login_as @profile
    token = @app.create_request_token

    @request.user_agent = 'blh blah iPhone blah blah'
    get :authorize, :oauth_token => token.token
    assert_equal 'layouts/mobile', @response.layout
  end

  test 'post authorize' do
    login_as @profile
    token = @app.create_request_token(:callback_url => 'http://foo.com')

    post :authorize, :oauth_token => token.token, :authorize => '1'
    token.reload
    assert_redirected_to "http://localhost/?oauth_token=#{token.token}&oauth_verifier=#{token.verifier}"

    assert_equal true, token.authorized?
    assert_equal @profile.user, token.user
  end


  test 'access_token' do
    login_as @profile
    request_token = @app.create_request_token
    request_token.authorize!(@profile)

    assert_difference 'AccessToken.count' do
      set_oauth1_headers(@app, request_token)
      get :access_token
      assert_response :success
    end

    access_token = AccessToken.first
    assert_equal @profile.user, access_token.user
    assert_match "oauth_token=#{access_token.token}", @response.body
    assert_match "oauth_token_secret=#{access_token.secret}", @response.body
  end

  # Ticket 19135
  test 'grant_type password allowed' do
    user = @profile.user
    password = 'foo'
    user.password = password
    user.save!
    @app.allow_grant_type_password!

    get :token, :grant_type => 'password', :client_id => @app.key, :client_secret => @app.secret, :username => user.primary_email.address, :password => password
    assert_response :success

    assert_match 'access_token', @response.body
  end

  # Ticket 19193
  test 'grant_type password allowed iphone' do
    user = @profile.user
    password = 'foo'
    user.password = password
    user.save!
    @app.allow_grant_type_password!

    @request.user_agent = 'iPhone'
    get :token, :grant_type => 'password', :client_id => @app.key, :client_secret => @app.secret, :username => user.primary_email.address, :password => password
    assert_response :success

    assert_equal ['access_token', 'expires_in'], from_json(@response.body).keys.sort, 'iPhone clients should get json'
  end

  # Ticket 19135
  test 'grant_type password denied' do
    get :token, :grant_type => 'password', :client_id => @app.key
    assert_response :forbidden
    assert_match 'not authorized', @response.body
  end

  # Ticket 19135
  test 'token with invalid client key' do
    get :token, :grant_type => 'password', :client_id => 'invalid'
    assert_redirected_to '/error'
    assert_match 'Invalid client key', flash[:error]
  end

  # Ticket 19177
  test 'validate_token invalid token' do
    get :validate_token, :access_token => 'invalid'
    assert_response :forbidden

    error =  from_json(@response.body)['error']
    assert_equal 'OAuthException', error['type']
    assert_match 'expired', error['message']
  end

  # Ticket 19177
  test 'validate_token valid token' do
    access_token = AccessToken.create(:user => @profile.user, :client_application => @app)
    get :validate_token, :access_token => access_token.token
    assert_response :success

    assert_equal 'OK', from_json(@response.body)['result']
  end

  # Ticket 16124
  test 'invalidate' do
    access_token = Oauth2Token.create(:user => @profile.user, :client_application => @app)
    get :invalidate, :access_token => access_token.token
    assert_response :success
    assert_equal 'OK', from_json(@response.body)['result'] # Ticket 19267
  end

private

  def dump_models
    pp [:apps, ClientApplication.all]
    pp [:tokens, OauthToken.all]
    pp [:nonces, OauthNonce.all]
  end

  def parse_response
    @response.body.split('&').inject({}) do |hash, parts|
      key, value = parts.split('=')
      hash.merge!(key.to_sym => value)
    end
  end
end
