class Platform::ApplicationPermissionFilter < Platform::BaseFilter
  
  def inner_joins
    [["Platform::Application", :application_id]]
  end

end
