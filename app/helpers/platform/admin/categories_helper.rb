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
    html.join("; \n")
  end
  
end
