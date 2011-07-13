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

# used only for platform in stand alone mode

class Platform::LoginController < Platform::BaseController

  skip_before_filter :validate_guest_user

  layout Platform::Config.site_info[:platform_layout]

  def index
    if request.post?
      user = Platform::PlatformUser.find_by_email_and_password(params[:email], params[:password])
      
      if user
        login!(user)
        return redirect_to("/platform/apps")
      end
      
      trfe('Incorrect email or password')
    end
  end

  def register
    if request.post?
      unless validate_registration
        user = Platform::PlatformUser.create(:email => params[:email], 
                  :password => params[:password], :name => params[:name], :gender => params[:gender], 
                  :mugshot => params[:mugshot], :link => params[:link])
        login!(user)
        
        trfn('Thank you for registering.')
        return redirect_to("/platform/apps")
      end
    end
  end

  def out
    logout!
    redirect_to("/platform") 
  end

private

  def validate_registration
    params[:email].strip!
     
    if params[:email].blank?
      return trfe('Email is missing')
    end

    translator = Platform::PlatformUser.find_by_email(params[:email])
    if translator
      return trfe('This email is already used by another user')
    end

    if params[:password].blank?
      return trfe('Password is missing')
    end
  end

end
