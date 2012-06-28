require File.dirname(__FILE__) + '/../../functional_test_helper'

class ClientApplicationTest < ActiveRecord::TestCase

  test 'create' do
    assert_difference 'ClientApplication.count', 1 do
      create_app
    end
  end

  test 'rate_limited' do
    app = ClientApplication.new
    assert_equal true, app.rate_limited?, 'Apps should be rate limited by default'

    app.rate_limited(false)
    assert_equal false, app.rate_limited?, 'Unable to un-limit app'

    app.rate_limited
    assert_equal true, app.rate_limited?, 'Unable to re-limit app'
  end

  # Ticket 19135
  test 'grant_type_password' do
    app = ClientApplication.new
    assert_equal false, app.allow_grant_type_password?, 'Apps should prevent grant_type_password by default'

    app.allow_grant_type_password
    assert_equal true, app.allow_grant_type_password?, 'Unable to allow grant_type_password'

    app.allow_grant_type_password(false)
    assert_equal false, app.allow_grant_type_password?, 'Unable to disallow grant_type_password'
  end

  # Ticket 19180
  test 'unlimited_models' do
    app = ClientApplication.new
    assert_equal false, app.allow_unlimited_models?, 'Apps should prevent unlimited_models by default'

    app.allow_unlimited_models
    assert_equal true, app.allow_unlimited_models?, 'Unable to allow unlimited_models'

    app.allow_unlimited_models(false)
    assert_equal false, app.allow_unlimited_models?, 'Unable to disallow unlimited_models'
  end

  # Ticket 19680
  test 'create sends email' do
    profile = Profile.create!(:first_name => 'first', :last_name => 'last', :claimed => true)

    Registry.api.with(:admin_email => 'scott.steadman@geni.com') do
      ClientApplication.create!(:user => profile.user, :name => 'name', :url => 'http://www.geni.com', :contact_email => 'foo@notgeni.com')
    end

    assert_equal 1, @emails.size
    assert_match 'has created', @emails.first.body.to_s
  end

  test 'last_token_for_user' do
    app = create_app

    profile = Profile.create!(:first_name => 'first', :last_name => 'last', :claimed => true)
    token1 = AccessToken.create(:client_application => app, :user => profile.user)
    token2 = AccessToken.create(:client_application => app, :user => profile.user)
    token3 = AccessToken.create(:client_application => app, :user => profile.user)

    assert_equal token3, app.last_token_for_user(profile.user)
    token3.destroy

    assert_equal token2, app.last_token_for_user(profile.user)
  end

  test 'valid_tokens_for_user' do
    app = create_app

    profile = Profile.create!(:first_name => 'first', :last_name => 'last', :claimed => true)
    token1 = AccessToken.create(:client_application => app, :user => profile.user)
    token2 = AccessToken.create(:client_application => app, :user => profile.user)
    token3 = AccessToken.create(:client_application => app, :user => profile.user)

    assert_equal 3, app.valid_tokens_for_user(profile.user).size
    token2.invalidate!

    assert_equal 2, app.valid_tokens_for_user(profile.user).size
  end

  test 'enable and disable' do
    app = create_app
    assert_equal false, app.enabled?
    app.enable!
    assert_equal true, app.enabled?
    app.disable!
    assert_equal false, app.enabled?
  end

private

  def create_app
    ClientApplication.create!(
        :name           => 'test',
        :url            => 'http://www.url.com',
        :callback_url   => 'http://www.callback.com',
        :contact_email  => 'foo@notgeni.com',
        :support_url    => 'http://www.support.com'
    )
  end

end
