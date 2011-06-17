require File.dirname(__FILE__) + '/../../functional_test_helper'

class RequestTokenTest < ActiveRecord::TestCase

  before(:all) do
    @profile = Profile.create
    @profile.claim!
    @app = ClientApplication.create
  end

  test 'authorize with user' do
    token = RequestToken.create(:client_application => @app)
    token.authorize!(@profile.user)
    assert_equal @profile.user, token.reload.user
  end

  test 'authorize with profile' do
    token = RequestToken.create(:client_application => @app)
    token.authorize!(@profile)
    assert_equal @profile.user, token.reload.user
  end

end
