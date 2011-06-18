
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
