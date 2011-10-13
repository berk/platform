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

Platform::Engine.routes.draw do
  
  match "apps", :to => "apps#index"
  match "apps/index", :to => "apps#index"
  match "apps/view", :to => "apps#view"
  match "apps/paginate_module", :to => "apps#paginate_module"
  match "apps/featured_applications_module_content", :to => "apps#featured_applications_module_content"
  match "apps/xd", :to => "apps#xd"
  match "apps(/:canvas_name)", :to => "apps#run"
  
  [:forum, :oauth, :ratings].each do |ctrl|
    match "#{ctrl}(/:action)", :controller => "#{ctrl}"
  end

  [:apps, :categories, :clientsdk, :developers, :exceptions, :forum, :metrics].each do |ctrl|
    match "admin/#{ctrl}(/:action)", :controller => "admin/#{ctrl}"
  end
  
  [:apps].each do |ctrl|
    match "api/#{ctrl}(/:action)", :controller => "api/#{ctrl}"
  end
  
  [:api_explorer, :apps, :blog, :dashboard, :forum, :help, :info, :registration, :resources].each do |ctrl|
    match "developer/#{ctrl}(/:action)", :controller => "developer/#{ctrl}"
  end
  
  namespace :admin do
    root :to => "admin/apps#index"
  end

  namespace :developer do
    root :to => "developer/apps#index"
  end

  root :to => "apps#index"
end
