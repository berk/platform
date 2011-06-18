module ApplicationHelper
  def will_filter(results)
    render(:partial => "/will_filter/filter/container", :locals => {:wf_filter => results.wf_filter})
  end

  def will_filter_scripts_tag
    render(:partial => "/will_filter/common/scripts")
  end
  
  def will_filter_table_tag(results, opts = {})
    filter = results.wf_filter
    opts[:columns] ||= filter.model_column_keys
    render(:partial => "/will_filter/common/results_table", :locals => {:results => results, :filter => filter, :opts => opts})
  end

  def will_filter_actions_bar_tag(results, actions, opts = {})
    filter = results.wf_filter
    opts[:class] ||= "wf_actions_bar_blue"
    opts[:style] ||= ""
    render(:partial => "/will_filter/common/actions_bar", :locals => {:results => results, :filter => filter, :actions => actions, :opts => opts})
  end
end
