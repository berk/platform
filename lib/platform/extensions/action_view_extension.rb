#--
# Copyright (c) 2010-2011 Michael Berkovich
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Platform
  module ActionViewExtension
    extend ActiveSupport::Concern
    module InstanceMethods
      def platform_user_login_tag(opts = {})
        opts[:class] ||= 'tr8n_right_horiz_list'
        render(:partial => '/platform/common/user_login', :locals => {:opts => opts})    
      end

      def platform_toggler_tag(content_id, label = "", open = true, opts = {})
        style = opts[:style] || 'text-align:center; vertical-align:middle'

        html = "<span id='#{content_id}_open' "
        html << "style='display:none'" unless open
        html << ">"
        html << link_to_function("#{image_tag("platform/arrow_down.gif", :style=>style)} #{label}".html_safe, "Tr8n.Effects.hide('#{content_id}_open'); Tr8n.Effects.show('#{content_id}_closed'); Tr8n.Effects.blindUp('#{content_id}');", :style=> "text-decoration:none")
        html << "</span>" 
        html << "<span id='#{content_id}_closed' "
        html << "style='display:none'" if open
        html << ">"
        html << link_to_function("#{image_tag("platform/arrow_right.gif", :style=>style)} #{label}".html_safe, "Tr8n.Effects.show('#{content_id}_open'); Tr8n.Effects.hide('#{content_id}_closed'); Tr8n.Effects.blindDown('#{content_id}');", :style=> "text-decoration:none")
        html << "</span>"
        html.html_safe 
      end  

      def platform_documentation_tag(url_options = {})
        link_to(image_tag("platform/bullet_go.png", :style=>"vertical-align:middle;"), url_options.merge({:controller => "/platform/developer/help", :action => "api"}))
      end

      def platform_documentation_field_decorators_tag(field)
        return unless field[:status]
        return image_tag("platform/cancel.png", :style=>"vertical-align:top;height:10px;", :title => trl("This field has been deprecated and will no longer be supported in the future versions")) if ['deprecated', 'removed'].include?(field[:status]) 
        return image_tag("platform/exclamation.png", :style=>"vertical-align:top;height:10px;", :title => trl("This field will be changed in the future versions")) if field[:status] == 'changed'
        return image_tag("platform/add.png", :style=>"vertical-align:top;height:10px;", :title => trl("This field has been added")) if field[:status] == 'added'
        return image_tag("platform/accept.png", :style=>"vertical-align:top;height:10px;", :title => trl("This field has been changed")) if field[:status] == 'updated'
      end

      def platform_documentation_api_decorators_tag(api)
        return unless api[:status]
        return image_tag("platform/exclamation.png", :style=>"vertical-align:top;height:10px;", :title => trl("The API structure has changed")) if ['changed'].include?(api[:status]) 
        return image_tag("platform/cancel.png", :style=>"vertical-align:top;height:10px;", :title => trl("The API has been removed")) if ['removed', 'deprecated'].include?(api[:status]) 
        return image_tag("platform/add.png", :style=>"vertical-align:top;height:10px;", :title => trl("This API has been added")) if api[:status] == 'added'
        return image_tag("platform/accept.png", :style=>"vertical-align:top;height:10px;", :title => trl("This API has been updated")) if api[:status] == 'updated'
      end

      def platform_scripts_tag(opts = {})
        render(:partial => '/platform/common/scripts', :locals => {:opts => opts})    
      end

      def platform_app_rank_tag(app, rank = nil, opts = {})
        return "" unless app

        rank ||= app.rank || 0
        rank = rank * 100 / 5

        html = "<span dir='ltr'>"
        1.upto(5) do |i|
          if rank > i * 20 - 10  and rank < i * 20  
            html << image_tag("platform/rating_star05.png")
          elsif rank < i * 20 - 10 
            html << image_tag("platform/rating_star0.png")
          else
            html << image_tag("platform/rating_star1.png")
          end 
        end
        html << "</span>"
        html.html_safe
      end

      def platform_rating_tag(rating, opts = {})
        return "" unless rating

        value = rating.value || 0
        style = []
        style << "width:#{opts[:width]}" if opts[:width]

        html = "<span dir='ltr'>"
        1.upto(5) do |i|
          if i <= value  
            html << image_tag("platform/rating_star1.png", :style => style.join(";"))
          else
            html << image_tag("platform/rating_star0.png", :style => style.join(";"))
          end 
        end
        html << "</span>"
        html.html_safe
      end

      def platform_spinner_tag(id = "spinner", label = nil, cls='spinner')
        html = "<div id='#{id}' class='#{cls}' style='display:none'>"
        html << image_tag("platform/spinner.gif", :style => "vertical-align:middle;")
        html << " #{trl(label)}" if label
        html << "</div>"
      end

      def platform_user_tag(user, options = {})
        return "Deleted Translator" unless user

        if options[:linked]
          link_to(Platform::Config.user_name(user), Platform::Config.user_link(user))
        else
          Platform::Config.user_name(user)
        end
      end

      def platform_user_mugshot_tag(user, options = {})
        if user and !Platform::Config.user_mugshot(user).blank?
          img_url = Platform::Config.user_mugshot(user)
        else
          img_url = Platform::Config.silhouette_image(user)
        end

        img_tag = "<img src='#{img_url}' style='width:48px'>"

        if user and options[:linked]
          link_to(img_tag, Platform::Config.user_link(user))
        else  
          img_tag
        end

        img_tag.html_safe
      end  

      def platform_login_url_tag(label)
        link_to(label, platform_stringify_url(Platform::Config.login_url, :display => params[:display], :client_id => params[:client_id]))
      end
      
      def platform_logout_url_tag(label)
        link_to(label, platform_stringify_url(Platform::Config.logout_url, :display => params[:display], :client_id => params[:client_id]))
      end

      def platform_paginator_tag(collection, options = {})  
        render :partial => "/platform/common/paginator", :locals => {:collection => collection, :options => options}
      end

      def platform_help_icon_tag(path = "index", opts = {})
        link_to(image_tag("platform/help.png", :style => "border:0px; vertical-align:middle;", :title => trl("Help")), opts.merge({:controller => "/platform/developer/help", :action => path}), :target => "_new")
      end

      def platform_stringify_url(path, params)
        "#{path}#{path.index('?') ? '&' : '?'}#{params.collect{|n,v| "#{n}=#{CGI.escape(v.to_s)}"}.join("&")}"
      end
      
      def platform_when_string_tr(key, opts = {})
        tr(key, 'Time reference', opts)
      end
      
      def platform_display_time(time, format)
        time.tr(format).gsub('/ ', '/').sub(/^[0:]*/,"")
      end
      
      def platform_when_string_tag(time, opts = {})
        elapsed_seconds = Time.now - time
        return platform_when_string_tr("Today") if time.today_in_time_zone? if opts[:days_only]
        return platform_when_string_tr('In the future, Marty!') if elapsed_seconds < 0
        return platform_when_string_tr('A moment ago') if elapsed_seconds < 2.minutes
        return platform_when_string_tr("{minutes||minute} ago", :minutes => (elapsed_seconds / 1.minute).to_i) if elapsed_seconds < 1.hour
        return platform_when_string_tr("{hours||hour} ago", :hours => 1) if elapsed_seconds < 1.75.hours
        return platform_when_string_tr("{hours||hour} ago", :hours => 2) if elapsed_seconds < 2.hours
        return platform_when_string_tr("{hours||hour} ago", :hours => (elapsed_seconds / 1.hour).to_i) if elapsed_seconds < 1.day
        return platform_when_string_tr("Yesterday") if elapsed_seconds < 48.hours
        return platform_when_string_tr("{days||day} ago", :days => elapsed_seconds.to_i / 1.day) if elapsed_seconds < 14.days
        return platform_when_string_tr("{weeks||week} ago", :weeks => (elapsed_seconds / 1.day / 7).to_i) if elapsed_weeks < 4
        return platform_display_time(time, :monthname_abbr) if Date.today.year == time.year
        return platform_display_time(time, :monthname_abbr_year)
      end      
      
    end
  end
end
