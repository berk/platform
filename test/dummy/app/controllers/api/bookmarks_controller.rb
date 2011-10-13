class Api::BookmarksController < Api::BaseController

  def index
    ensure_get
    render_response page_model
  end

  def create
    raise BadRequestError.new("Title and url must be provided") if params[:title].blank? or params[:url].blank?
    bookmark = Bookmark.create(:user => current_user, :title => params[:title], :url => params[:url])
    return redirect_to(params[:url]) if params[:bookmarklet]
    render_response bookmark
  end
  
  def update
    ensure_ownership
    raise BadRequestError.new("Title and url must be provided") if params[:title].blank? or params[:url].blank?
    page_model.update_attributes(params.slice(:title, :url))
    render_response page_model
  end
  
  def delete
    ensure_post    
    ensure_ownership
    page_model.destroy
    render_response success_message
  end
  
private
  
  def model_class
    Bookmark
  end
  
end