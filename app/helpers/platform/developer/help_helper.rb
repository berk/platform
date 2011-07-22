#--
# Copyright (c) 2011 Michael Berkovich, Geni Inc
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

module Platform::Developer::HelpHelper

  def documentation_field_type_tag(field)
    return field[:type] if simple_field?(field[:type])
    if field[:type] == "Array"
      return "Array of #{field[:array_type]}" if simple_field?(field[:array_type])
      return "Array of #{documentation_field_link_tag(field[:array_type].pluralize, field[:array_type])}" 
    end
    documentation_field_link_tag(field[:type], field[:type])
  end
  
  def documentation_field_link_tag(name, type)
    link_to(name, :controller => "/platform/developer/help", :action => :api, :path => type.underscore)
  end
  
  def documentation_field_decorators_tag(field)
    html = []
    html << image_tag("/platform/images/exclamation.png", :style=>"vertical-align:top;height:10px;", :title => trl("This field has been deprecated")) if field[:deprecated]
    html << image_tag("/platform/images/add.png", :style=>"vertical-align:top;height:10px;", :title => trl("This field has been added")) if field[:added]
    html << image_tag("/platform/images/accept.png", :style=>"vertical-align:top;height:10px;", :title => trl("This field has been changed")) if field[:updated]
    html.join("")
  end

  def documentation_api_decorators_tag(api)
    html = []
    html << image_tag("/platform/images/exclamation.png", :style=>"vertical-align:top;height:10px;", :title => trl("The API structure has changed")) if api[:changed]
    html << image_tag("/platform/images/add.png", :style=>"vertical-align:top;height:10px;", :title => trl("This API has been added")) if api[:added]
    html << image_tag("/platform/images/accept.png", :style=>"vertical-align:top;height:10px;", :title => trl("This API has been updated")) if api[:updated]
    html << image_tag("/platform/images/exclamation.png", :style=>"vertical-align:top;height:10px;", :title => trl("This API has been deprecated")) if api[:removed]
    html.join("")
  end
  
private

  def simple_field?(type)
    ["String", "Number", "Boolean", "Array or String", "Hash"].include?(type)
  end
  
end