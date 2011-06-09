module Platform::Developer::DashboardHelper

  def daily_active_users_chart(developer)
    values = [100, 200, 500]
    names = ["Not Translated", "Translated", "Pending Approval"]
    colors = ['FF0000', '00FF00', 'FFFF00']
    chart_url = "https://chart.googleapis.com/chart?cht=p3&chs=350x80&chd=t:#{values.join(',')}&chl=#{names.join('|')}&chco=#{colors.join('|')}"
    image_tag(chart_url)
  end

  def daily_new_users_chart(app)
    values = [100, 200, 500]
    names = ["Not Translated", "Translated", "Pending Approval"]
    colors = ['FF0000', '00FF00', 'FFFF00']
    chart_url = "https://chart.googleapis.com/chart?cht=p3&chs=350x80&chd=t:#{values.join(',')}&chl=#{names.join('|')}&chco=#{colors.join('|')}"
    image_tag(chart_url)
  end

end