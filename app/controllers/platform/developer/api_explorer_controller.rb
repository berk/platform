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

class Platform::Developer::ApiExplorerController < Platform::Developer::BaseController
  
  skip_filter filter_chain

  before_filter :prepare_api_version
  
  def index
    @api_history = "[]"
    @api_history = request.cookies["api_history"] unless request.cookies["api_history"].blank?
    @api_history_index = request.cookies["api_history_index"] || 0
  end

  def history
    @api_history = []
    @api_history = JSON.parse(request.cookies["api_history"]) unless request.cookies["api_history"].blank?
    @api_history_index = (params["api_history_index"] || -1).to_i
    
    render(:layout => false)
  end
  
  def options
    render(:layout => false)
  end
  
  def oauth_lander
    render :layout => false
  end
  
private
 
  def prepare_api_version
    @api_version = params[:api_version] || Platform::Config.api_default_version
  end
    
end
