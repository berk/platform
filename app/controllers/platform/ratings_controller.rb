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

class Platform::RatingsController < Platform::BaseController

  def submit_app_rating
    app = Platform::Application.find(params[:app_id])
    
    if request.post?
      rating = Platform::Rating.find_or_create(app, Platform::Config.current_user)
      
      rating_value = params[:rating_value].to_i
      if rating_value < 0 or rating_value > 5
        trfe("Invalid application rating value")
        return redirect_to_source
      end
      rating.value = rating_value
      
      rating.comment = params[:rating_comment].blank? ? nil : params[:rating_comment]
      rating.save

      app.update_rank!
    end  
    
    redirect_to_source
  end
  
  def delete_app_rating
    rating = Platform::Rating.find(params[:rating_id])
    
    if rating and rating.user_id == Platform::Config.current_user.id
      rating.destroy 
      rating.object.update_rank!
    else
      trfe("Invalid application rating")
    end
    
    redirect_to_source
  end
  
end
