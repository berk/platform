#--
# Copyright (c) 2011 Michael Berkovich
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

module Platform::Admin::CategoriesHelper
 
  def generate_tree(html, parent, parent_name, checkboxes=false) 
    parent.children.each_with_index do |child, index|
      name = "#{parent_name}_#{index}"
      child_name = child.name.gsub("'", "\\'")
      action = "javascript:openSubCategory(\"#{child.id}\", \"#{child_name}\");"
      action = "" if checkboxes
      checkbox_action = "onClick='assignCategory(this)'"
      
      html << "#{name} = insFld(#{parent_name}, gFld('&nbsp;<span class=tree_item>#{child_name.gsub("'", "\\'")}</span>', '#{action}'))"
      html << "#{name}.xID = '#{child.id}'"
      if checkboxes and child.children.size == 0
        html << "#{name}.prependHTML = \"<td valign=middle align=left width=40px><input #{checkbox_action} type=checkbox id='check_#{child.id}'></td>\""
      end
      generate_tree(html, child, name, checkboxes) 
    end
  end
  
  def generate_categories_javascript(root, checkboxes=false)
    html = []
    action = "javascript:openSubCategory(\"#{root.id}\", \"#{root.name}\");"
    action = "" if checkboxes
    html << "foldersTree = gFld('&nbsp;<span class=tree_root>#{root.name.gsub("'", "\\'")}</span>', '#{action}')"
    html << "foldersTree.treeID = 'categoriesTree'"
    html << "foldersTree.xID = '#{root.id}'"
    generate_tree(html, root, "foldersTree", checkboxes)
    html.join("; \n").html_safe
  end
  
end
