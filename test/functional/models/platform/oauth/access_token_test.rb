require File.dirname(__FILE__) + '/../../functional_test_helper'

class AccessTokenTest < ActiveRecord::TestCase

  before(:all) do
    @profile = create_claimed_profile
    @app = ClientApplication.create
  end

  # Ticket 19802
  test 'valid_to set on creation' do
    token = AccessToken.create!(:client_application => @app, :user => @profile.user)
    assert_equal false, token.valid_to.nil?
  end

  # Ticket 19802
  test 'to_json' do
    token = AccessToken.create!(:client_application => @app, :user => @profile.user)
    json = token.to_json
    assert_match token.token, json
    assert_match token.try(:lifetime).to_s, json
  end


end
