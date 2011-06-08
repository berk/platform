class Platform::Admin::CategoriesController < Platform::Admin::BaseController

  def index
    @root = Platform::Category.root
    @category =  Platform::Category.find(params[:category_id]) if params[:category_id]
    @category ||= @root
  end

  def tree
    @root = Platform::Category.root
    @category =  Platform::Category.find(params[:category_id]) if params[:category_id]
    @category ||= @root
    render  :layout => false
  end

  def items
    @parent = Platform::Category.find(params[:parent_id])
    @children = @parent.children if params[:sub_categories] == "true"
    @items = @parent.category_items if params[:objects] == "true"
    
    render  :layout => false
  end

  def lb_update_category
    @parent = Platform::Category.find(params[:parent_id]) if params[:parent_id]
    @category = Platform::Category.find(params[:category_id]) if params[:category_id]
    @category = Platform::Category.new(:parent_id=>params[:parent_id]) unless @category
    render  :layout => false
  end

  def update_category
    if params[:category][:id] != "" 
      @category = Platform::Category.find(params[:category][:id])
      @category.update_attributes(params[:category])
    else
      @category = Platform::Category.create(params[:category])
    end
    
    redirect_to :action => :index, :category_id => @category.id
  end

  def lb_update_category_item
    @cat_item = Platform::CategoryItem.find(params[:cat_item_id])
    render  :layout => false
  end

  def update_category_item
    @cat_item = Platform::CategoryItem.find(params[:category_item][:id])
    @cat_item.update_attributes(params[:category_item])
    flash[:notice] = 'Category Item was successfully updated.'
    redirect_to :action => :index, :category_id => @cat_item.category.id
  end

  def delete_category
    recursive_category_delete(params[:category_id])
    flash[:notice] = 'Category was successfully deleted.'
    redirect_to :action => :index
  end

  def assign_category
    cls = params[:item_type].constantize
    item = cls.find(params[:item_id])
    category = Platform::Category.find(params[:category_id])
    
    if params[:job] == "destroy"
      item.remove_category(category)
    else
      item.add_category(category)
    end

    item.reload
    categories_text = item.category_names 
    
    render :text=>categories_text
  end
  
  def category_assigner
    @item_id = params[:item_id]
    @item_type = params[:item_type]

    @root_keyword = params[:root_keyword] || "root"

    cls = @item_type.constantize
    @item = cls.find(@item_id.to_i)    

    @root = Platform::Category.find_by_keyword(@root_keyword)
    
    render :layout=>false
  end
  
  def loading_assigner
    render :layout=>false
  end
  
private

  def recursive_category_delete(cat_id)
    cat = Platform::Category.find(cat_id)
    Platform::CategoryItem.delete_all(["category_id=?", cat_id])
    
    cat.children.each do |sub_cat|
      recursive_category_delete(sub_cat.id)
    end

    cat.destroy
  end

end
