#--
# Copyright (c) 2011 Michael Berkovich, Geni Inc
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

class Platform::Developer::HelpController < Platform::Developer::BaseController
  
  before_filter :set_version
  
  def index
    
  end

  def reference
    
  end
  
  def oauth_intro
    
  end

  def oauth_server_side
    
  end

  def oauth_client_side
    
  end

  def oauth_trusted_client
    
  end
  
  def oauth_app_login
    
  end
    
  def oauth_desktop
    
  end

  def oauth_mobile
    
  end
  
  def sdk_js
    
  end
  
  def sdk_ios
    
  end
  
  def api
    ref = Platform::Config.api_reference(@version) 
    unless ref
      trfe("Unsupported API version")
      return redirect_to(:action => :index, :version => @version)
    end
        
    if params[:path].blank?
      trfe("API path must be provided")
      return redirect_to(:action => :index, :version => @version)
    end
    
    parts = params[:path].split("/")
    parts.delete(parts.first) if [''].include?(parts.first)
    
    @api = ref[parts.first]
    unless @api
      trfe("Unsupported API path")
      return redirect_to(:action => :index, :version => @version)
    end
    
    if parts.size > 1 
      if @api[:actions] and @api[:actions][parts.last]
        action_api = @api[:actions][parts.last]
        action_api[:parent] = @api
        @api = action_api
      else  
        trfe("Unsupported API path")
      end
    end
  end

private

  def set_version
    @version = params[:version] || Platform::Config.api_default_version
  end
end
