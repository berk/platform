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
  module ActionControllerExtension
    def self.included(base)
      base.send(:include, InstanceMethods) 
    end

    module InstanceMethods
      def platform_redirect_to_oauth
        if platform_oauth_redirect_params
          redirect_to(platform_oauth_redirect_params)
          return true
        end
        false
      end

      def platform_store_oauth_redirect_params
        session[:platform_oauth_redirect_params] = params
      end

      def platform_remove_oauth_redirect_params
        session[:platform_oauth_redirect_params] = nil
      end
      
      def platform_oauth_redirect_params
        session[:platform_oauth_redirect_params]
      end
      
      def platform_login_url
        platform_stringify_url(Platform::Config.login_url, :display => params[:display], :client_id => params[:client_id])
      end
      
      def platform_logout_url
        platform_stringify_url(Platform::Config.logout_url, :display => params[:display], :client_id => params[:client_id])
      end

      def platform_stringify_url(path, params)
        "#{path}#{path.index('?') ? '&' : '?'}#{params.collect{|n,v| "#{n}=#{CGI.escape(v.to_s)}"}.join("&")}"
      end

    end
  end
end
