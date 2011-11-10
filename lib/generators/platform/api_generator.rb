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
  module Generators
    class ApiGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      desc "Creates an API proxy file for your model"
      def create_proxy_file
        create_file "#{Rails.root}/app/controllers/api/#{file_name}_controller.rb", %Q{class Api::#{class_name}Controller < Api::BaseController
  def index
    ensure_get
    ensure_ids_provided
    ensure_ownership
    render_response page_models
  end

  def create
    ensure_logged_in
    # TODO: create object
    render_response object
  end
  
  def update
    ensure_logged_in
    ensure_ownership
    # TODO: update object
    render_response object
  end
  
  def delete
    ensure_logged_in
    ensure_post    
    ensure_ownership
    # TODO: delete object
    render_response success_message
  end
  
private

  def model_class
    #{class_name}
  end
  
end
      }        
      end
      
    private
    
    end
  end
end