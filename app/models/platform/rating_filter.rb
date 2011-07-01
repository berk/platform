class Platform::RatingFilter < Platform::BaseFilter

  def default_filter_if_empty
    "created_today"
  end

end
