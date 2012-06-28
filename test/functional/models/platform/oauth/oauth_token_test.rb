require File.dirname(__FILE__) + '/../../functional_test_helper'

class OauthTokenTest < ActiveRecord::TestCase

  before(:all) do
    @profile = create_claimed_profile
    @app = ClientApplication.create
  end

  test 'user assignment with profile' do
    token = OauthToken.create!(:client_application => @app, :user => @profile.user)
    assert_equal @profile.user, token.reload.user
  end

  # Ticket 19802
  test 'invalidated? sets invalidated_at' do
    token = OauthToken.create!(:client_application => @app, :user => @profile.user, :valid_to => Time.now - 5.minutes)
    assert_equal true, token.invalidated_at.nil?
    assert_equal true, token.invalidated?
    assert_equal false, token.invalidated_at.nil?
  end

end
