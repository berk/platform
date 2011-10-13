class Api::UsersController < Api::BaseController

  def index
    ensure_get
    render_response current_user
  end
  
  def bookmarks
    ensure_logged_in
    ensure_get
    render_response current_user.bookmarks
  end
  
private

  def model_class
    User
  end
  
end