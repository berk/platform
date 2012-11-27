#--
# Copyright (c) 2011 Michael Berkovich
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class Platform::Admin::AppsController < Platform::Admin::BaseController

  def index
    @apps = Platform::Application.filter(:params => params, :filter => Platform::ApplicationFilter)
  end

  def view
    @app = Platform::Application.find(params[:app_id])
  end
  
  def tokens
    @tokens = Platform::Oauth::OauthToken.filter(:params => params, :filter => Platform::Oauth::OauthTokenFilter)
  end

  def users
    @users = Platform::ApplicationUser.filter(:params => params, :filter => Platform::ApplicationUserFilter)
  end

  # def authorizations
  #   @permissions = Platform::ApplicationPermission.filter(:params => params, :filter => Platform::ApplicationPermissionFilter)
  # end

  def permissions
    @permissions = Platform::Permission.filter(:params => params, :filter => Platform::PermissionFilter)
  end

  def lb_permission
    @permission = Platform::Permission.find_by_id(params[:perm_id]) if params[:perm_id]
    @permission ||= Platform::Permission.new
    
    if request.post?
      if @permission.id.nil?
        @permission = Platform::Permission.create(params[:permission])
      else
        @permission.update_attributes(params[:permission])
      end

      @permission.store_icon(params[:new_icon]) unless params[:new_icon].blank?

      return redirect_to_source(:action => :permissions)    
    end
    
    render :layout => false
  end

  def delete_permission
    @permission = Platform::Permission.find_by_id(params[:perm_id]) if params[:perm_id]
    @permission.destroy if @permission
    redirect_to_source(:action => :permissions)
  end

  def ratings
    @ratings = Platform::Rating.filter(:params => params, :filter => Platform::RatingFilter)
  end

  def block
    app = Platform::Application.find(params[:app_id])  
    app.block!
    
    app.children.each do |child|
      child.block!
    end
    
    redirect_to(:action => :view, :app_id => app.id)
  end

  def unblock
    app = Platform::Application.find(params[:app_id])  
    app.unblock!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def approve
    app = Platform::Application.find(params[:app_id])
    
    app.children.each do |child|
      child.deprecate!
    end
    
    app.approve!
    
    redirect_to(:action => :view, :app_id => app.id)
  end

  def reject
    app = Platform::Application.find(params[:app_id])  
    app.reject!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def set_permission
    app = Platform::Application.find(params[:app_id])  
    app.set_permission(params[:perm], true)
    app.save
    redirect_to(:action => :view, :app_id => app.id)
  end

  def remove_permission
    app = Platform::Application.find(params[:app_id])  
    app.set_permission(params[:perm], false)
    app.save
    redirect_to(:action => :view, :app_id => app.id)
  end
  
  def lb_edit
    @app = Platform::Application.find_by_id(params[:app_id])
    render :layout => false
  end
  
  def update
    if request.post?
      app = Platform::Application.find_by_id(params[:app_id]) if params[:app_id]
      if app
        app.update_attributes(params[:app]) 
        app.store_icon(params[:new_icon]) unless params[:new_icon].blank?
        app.store_logo(params[:new_logo]) unless params[:new_logo].blank?
      end
    end
    
    redirect_to_source(:action => :index)    
  end
  
end
