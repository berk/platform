class Platform::ApplicationFilter < Platform::BaseFilter
  
  def inner_joins
    [["Platform::Developer", :developer_id]]
  end

end
