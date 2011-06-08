class Platform::Oauth::OauthTokenFilter <  Wf::Filter

  def default_filters
    [
      ["Created today", "created_today"]
    ]
  end

  def default_filter_conditions(key)
    if (key=="created_today")
      return [:created_at, :is_on, Date.today]
    end
  end

  def default_filter_if_empty
    "created_today"
  end

end
