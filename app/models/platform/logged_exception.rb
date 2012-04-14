#--
# Copyright (c) 2010-2012 Michael Berkovich
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
#
#-- Platform::LoggedException Schema Information
#
# Table name: platform_logged_exceptions
#
#  id                 INTEGER         not null, primary key
#  exception_class    varchar(255)    
#  controller_name    varchar(255)    
#  action_name        varchar(255)    
#  server             varchar(255)    
#  message            text            
#  backtrace          text            
#  environment        text            
#  request            text            
#  session            text            
#  cause              blob            
#  user_id            integer         
#  application_id     integer         
#  created_at         datetime        
#  updated_at         datetime        
#
# Indexes
#
#
#++

class Platform::LoggedException < ActiveRecord::Base
  set_table_name :platform_logged_exceptions

  serialize :cause
  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :application, :class_name => "Platform::Application", :foreign_key => :application_id

  def self.create_from_exception(controller, exception, data)
    message = exception.message.inspect
    message << "\n* Extra Data\n\n#{Iconv.conv('UTF-8//IGNORE', 'UTF-8', data)}" unless data.blank?
    create!(
      :exception_class => exception.class.name,
      :controller_name => controller.controller_name,
      :action_name     => controller.action_name,
      :server          => host_name,
      :message         => message,
      :backtrace       => exception.backtrace,
      :session         => controller.request.session,
      :request         => controller.request,
      :user_id         => Platform::Config.current_user.try(:id)
      # :cause           => exception.try(:cause)
    )
  rescue StandardError => ex
    pp ex
    logger.warn { "Unable to log this error: #{exception.message}\n#{exception.backtrace.inspect}" }
    logger.warn { "Because: #{ex.message}\n#{ex.backtrace.inspect}" }
  end

  def self.log(exception, opts=nil)
    opts ||= {}

    controller = opts[:controller] || opts[:class]  || ''
    action     = opts[:action]     || opts[:method] || ''

    unless Rails.env.test?
      puts "Caught Exception #{exception.message}"
      puts exception.backtrace.join("\n") if exception.backtrace
    end

    ret = create(
      :exception_class => exception.class.name,
      :server          => host_name,
      :message         => exception.message.inspect,
      :backtrace       => exception.backtrace,
      :controller_name => controller.to_s,
      :action_name     => action.to_s,
      :user_id         => Platform::Config.current_user.try(:id),
      :cause           => exception.try(:cause)
    )

    email_exception(ret, opts[:mail_to]) if opts[:mail_to]

    ret
  rescue ActiveRecord::ActiveRecordError
    # don't puke if we can't log the exception
  end

  def self.controllers
    @controllers ||= connection.select_values(%Q{
      select distinct controller_name
        from #{table_name}
    })
  end

  def self.actions
    @actions ||= connection.select_all(%Q{
      select controller_name, action_name
        from #{table_name}
        group by controller_name, action_name
    }).map {|ii| "#{ii['controller_name']}/#{ii['action_name']}"}
  end

  def self.action_names
    @action_names ||= connection.select_values(%Q{
      select distinct action_name
        from #{table_name}
    })
  end

  def self.action_name_summary(opts=nil)
    opts ||= {}
    order = opts[:order] || 'action_name'
    where_clause = opts[:conditions] ? "where #{sanitize_sql(opts[:conditions])}" : nil
    connection.select_all(%Q{
      select action_name, count(*)
        from #{table_name}
        #{where_clause}
        group by action_name
        order by #{order}
    })
  end

  def self.exception_class_summary(opts=nil)
    opts ||= {}
    order = opts[:order] || 'exception_class'
    where_clause = opts[:conditions] ? "where #{sanitize_sql(opts[:conditions])}" : nil
    connection.select_all(%Q{
      select exception_class, count(*)
        from #{table_name}
        #{where_clause}
        group by exception_class
        order by #{order}
    })
  end

  def self.controller_summary(opts=nil)
    opts ||= {}
    order = opts[:order] || 'controller_name'
    where_clause = opts[:conditions] ? "where #{sanitize_sql(opts[:conditions])}" : nil
    connection.select_all(%Q{
      select controller_name, count(*)
        from #{table_name}
        #{where_clause}
        group by controller_name
        order by #{order}
    })
  end

  def self.action_summary(opts=nil)
    opts ||= {}
    order = opts[:order] || 'controller_name, action_name'
    where_clause = opts[:conditions] ? "where #{sanitize_sql(opts[:conditions])}" : nil
    connection.select_all(%Q{
      select controller_name, action_name, count(*)
        from #{table_name}
        #{where_clause}
        group by controller_name, action_name
        order by #{order}
    })
  end

  def self.exceptions
    @exceptions ||= connection.select_values(%Q{
      select distinct exception_class
        from #{table_name}
        order by exception_class
    })
  end

  def self.exception_summary(opts=nil)
    opts ||= {}
    order = opts[:order] || 'exception_class'
    where_clause = opts[:conditions] ? "where #{sanitize_sql(opts[:conditions])}" : nil
    connection.select_all(%Q{
      select exception_class, count(*)
        from #{table_name}
        #{where_clause}
        group by exception_class
        order by #{order}
    })
  end

  def self.dates
    @dates ||= connection.select_values(%Q{
      select distinct date(created_at)
        from #{table_name}
    })
  end

  def self.date_summary(opts=nil)
    opts ||= {}
    order = opts[:order] || 'datestamp desc'
    where_clause = opts[:conditions] ? "where #{sanitize_sql(opts[:conditions])}" : nil
    connection.select_all(%Q{
      select date(created_at) as datestamp, count(*)
        from #{table_name}
        #{where_clause}
        group by datestamp
        order by #{order}
    })
  end

  def self.exception_report(date)
    connection.select_all(%Q{
      select exception_class, controller_name, action_name, count(*) as count
        from #{table_name}
        where date(created_at) = '#{date}'
        group by exception_class, controller_name, action_name
    }).inject({}) do |ret, hash|
      ex = hash['exception_class']
      controller_action = "#{hash['controller_name']}/#{hash['action_name']}"
      ret[ex] ||= {}
      ret[ex][:total] ||= 0
      ret[ex][:total] += hash['count'].to_i
      ret[ex][controller_action] = hash['count']

      ret
    end
  end

  def self.purge(days_to_keep)
    days_to_keep -= 1 # include today's logs
    delete_all(["created_at <= ?", Date.today - days_to_keep])
  end

  def self.host_name
    @host_name ||= Socket.gethostname
  end

  def backtrace=(backtrace)
    return if backtrace.nil?
    backtrace = sanitize_backtrace(backtrace) * "\n" unless backtrace.is_a?(String)
    write_attribute :backtrace, backtrace
  end

  def session=(session)
    case session
      when String
        write_attribute(:session, session)
      else
        write_attribute(:session,
          [:@session_id, :@data].map do |variable|
            "* #{variable}:\n" <<
            PP.pp(session.instance_variable_get(variable), '').gsub(/\n/, "\n    ").strip
          end * "\n"
        )
    end
  end

  def request=(request)
    if request.is_a?(String)
      write_attribute :request, request
    else
      request.env['Process'] = $$
      max = request.env.keys.max { |a,b| a.length <=> b.length }
      env = request.env.keys.sort.inject([]) do |array, key|
        array << '* ' + ("%-*s: %s" % [max.length, key, request.env[key].to_s.strip])
      end
      write_attribute(:environment, env.join("\n"))

      write_attribute(:request, [
        "* URL:#{" #{request.method.to_s.upcase}" unless request.get?} #{request.protocol}#{request.env["HTTP_HOST"]}#{request.url}",
        "* Format: #{request.format.to_s}",
        "* Parameters: #{request.parameters.reject{|key, value| rejected_parameters.include?(key.to_sym)}.inspect}",
        "* Rails Root: #{Rails.root}"
      ] * "\n")
    end
  end

  def rejected_parameters
    [:password]
  end

  def controller_action
    @controller_action ||= "#{controller_name.camelcase}/#{action_name}"
  end

  private

    def sanitize_backtrace(trace)
      trace
    end

    def self.email_exception(log, to)
      message = []

      message << "Subject: #{log.exception_class}: #{log.message}\n"
      message << "Exception URL: #{Platform.site_url}/admin/exceptions/show/#{log.id}"
      message << "Backtrace:\n#{log.backtrace.join("\n")}" if log.backtrace

      Net::SMTP.start(LOCAL_SMTP_SETTINGS[:address], LOCAL_SMTP_SETTINGS[:port]) do |smtp|
        smtp.send_message message.join("\n"), Platform::Config.api[:admin_email], to
      end

    end

end
