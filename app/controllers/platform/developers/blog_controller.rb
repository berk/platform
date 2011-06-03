class Platform::Developers::BlogController < Platform::BaseController
  before_filter :redirect_if_not_logged_in
  skip_before_filter :init_page_profile

  def welcome
    redirect_to(:controller => '/developers/apps', :action => :index)    
  end
  
  def index
    @apps = own_profile.client_applications
    @page_title = tr('Developers Blog', 'Client application controller title')
  end
  
end
