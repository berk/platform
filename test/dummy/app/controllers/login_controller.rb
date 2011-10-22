class LoginController < ApplicationController

  layout :login_layout
  
  def index
    if request.post?
      user = User.find_by_email_and_password(params[:email], params[:password])
      
      if user
        login!(user)
        return if platform_redirect_to_oauth
        return redirect_to("/platform/apps")
      end
      
      trfe('Incorrect email or password')
    end
  end

  def register
    if request.post?
      unless validate_registration
        user = User.create(:email => params[:email], 
                  :password => params[:password], 
                  :first_name => params[:first_name], 
                  :last_name => params[:last_name], 
                  :gender => params[:gender])
        login!(user)
        
        return if platform_redirect_to_oauth
        trfn('Thank you for registering.')
        return redirect_to("/platform/apps")
      end
    end
  end

  def out
    logout!
    redirect_to(params.merge(:action => :index)) 
  end

private
  
  def login_layout
    return 'mobile' if params[:display] == 'mobile'
    return 'minimal' if params[:display] == 'popup'
    'application'
  end
  
  def validate_registration
    params[:email].strip!
     
    if params[:email].blank?
      return trfe('Email is missing')
    end

    user = User.find_by_email(params[:email])
    if user
      return trfe('This email is already used by another user')
    end

    if params[:password].blank?
      return trfe('Password is missing')
    end
  end

end
