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
