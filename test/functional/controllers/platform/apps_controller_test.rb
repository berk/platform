require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb') 

class Platform::AppsControllerTest < ActionController::TestCase

  def setup
    @profile = create_claimed_profile
  end

  test 'index requires login' do
    get :index
    assert_redirected_to '/login'
  end

  test 'index with apps directory disabled' do
    Registry.apps.with(:apps_directory_enabled => false) do
      login_as @profile
      get :index
      assert_redirected_to :controller => '/developers/apps', :action => 'index'
    end
  end

  test 'index with apps directory enabled' do
    Registry.apps.with(:apps_directory_enabled => true) do
      login_as @profile
      get :index
      assert_response :success
    end
  end

end
