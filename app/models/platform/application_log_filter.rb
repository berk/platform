class Platform::ApplicationLogFilter < Platform::BaseFilter
  
  def inner_joins
    [["Platform::Application", :application_id]]
  end

  def default_filter_if_empty
    "created_today"
  end

end
