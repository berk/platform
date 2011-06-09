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

class Platform::Developer::BaseController < Platform::BaseController

  before_filter :validate_developer

private

  def platform_developer_tabs
    [
        {"title" => "Dashboard", "description" => "Developer tab", "controller" => "dashboard"},
        {"title" => "Applications", "description" => "Developer tab", "controller" => "apps"},
        {"title" => "Discussions", "description" => "Developer tab", "controller" => "forum"},
        {"title" => "Help", "description" => "Developer tab", "controller" => "help"}
    ]
  end
  helper_method :platform_developer_tabs

  def validate_developer
    unless platform_current_user_is_developer?
      return redirect_to("/platform/developer/registration")
    end
  end
  
end