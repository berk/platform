class Admin::BookmarksController < Admin::BaseController
  
  def index
    @bookmarks = Bookmark.filter(:params => params)
  end

end
