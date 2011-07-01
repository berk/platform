class Platform::BaseFilter < Wf::Filter

  def default_filters
    [
      ["Created Today", "created_today"],
      ["Updated Today", "updated_today"]
    ]
  end

  def default_filter_conditions(key)
    return [:created_at, :is_on, Date.today] if (key == "created_today")
    return [:updated_at, :is_on, Date.today] if (key == "updated_today")
  end
  
  def default_order
    'created_at'
  end
  
  def default_order_type
    'desc'
  end
  
end
