#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
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

class Platform::Admin::BaseController < Platform::BaseController

  if Platform::Config.admin_helpers.any?
    helper *Platform::Config.admin_helpers
  end

  before_filter :validate_admin
  
  layout Platform::Config.admin_layout
  
private

  def validate_platform_enabled
    # don't do anything for admin pages
  end
  
  def platform_admin_tabs
    [
        {"title" => "Applications", "description" => "Admin tab", "controller" => "apps"},
        {"title" => "Developers", "description" => "Admin tab", "controller" => "developers"},
        {"title" => "Categories", "description" => "Admin tab", "controller" => "categories"}
    ]
  end
  helper_method :platform_admin_tabs

  def validate_admin
    unless platform_current_user_is_admin?
      trfe("You must be an admin in order to view this section of the site")
      redirect_to_site_default_url
    end
  end
  
end