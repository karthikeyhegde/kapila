class ItemsController < ApplicationController

 def index
  @items = Item.all
 end

 def show
 end

 def new
  @item = Item.new
  @form_method = 'post'
 end

 def create
  @item = Item.new(params[:item])
  @item.save!
  redirect_to :action => 'index'
 end

 def edit
  @item = Item.find(params[:id])
  @form_method = 'update'
 end

 def update
  @item = Item.find(params[:id])
  @item.update_attributes(params[:item])
  redirect_to :action => 'index'
 end

 def destroy
  redirect_to :action => 'index'
 end

 def remove
   Item.find(params[:id]).destroy
   redirect_to :action => 'index'
 end

 def rep_txnitems
    @item = Item.find(params[:id])
    @txn_items = @item.rep_ixnitems
 end 

 def all_search
     p "DDERT"
    search_str = params[:search]
    ssearch = '%'+search_str+'%'
    @contacts = Contact.where(" LOWER (name) LIKE  LOWER (?)  OR LOWER (subname)  LIKE LOWER (?) OR LOWER (place) LIKE LOWER (?) OR LOWER (contact_type) LIKE LOWER (?)",ssearch,ssearch,ssearch,ssearch)
    @items = Item.where(" LOWER (name)  LIKE LOWER(?)",ssearch)
   
    @sites = Site.where(" LOWER (name) LIKE LOWER (?) OR LOWER (place) LIKE LOWER (?) ",ssearch,ssearch )
    
 end 

end
