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
   begin
   Item.find(params[:id]).destroy
   redirect_to :action => 'index'
 rescue Exception => e
   p e.to_s
   p e.baktrace
 end 
 end

 def rep_txnitems
    @item = Item.find(params[:id])
    @txn_items = @item.txn_items
    @all_sum = 0
    @all_numbers = 0
    @txn_items.each{|s| 
      @all_sum +=  (s.transaction.buyback == 1 ? (-1 * s.amount.to_f) : s.amount.to_f)
      @all_numbers += ( s.transaction.buyback == 1 ? (-1 * s.number.to_i) : s.number.to_i)
    }
    
 end 

 def all_search
    search_str = params[:search]
    ssearch = '%'+search_str+'%'
    @contacts = Contact.where(" LOWER (name) LIKE  LOWER (?)  OR LOWER (subname)  LIKE LOWER (?) OR LOWER (place) LIKE LOWER (?) OR LOWER (contact_type) LIKE LOWER (?)",ssearch,ssearch,ssearch,ssearch)
    @items = Item.where(" LOWER (name)  LIKE LOWER(?)",ssearch)
    @sites = Site.where(" LOWER (name) LIKE LOWER (?) OR LOWER (place) LIKE LOWER (?) ",ssearch,ssearch )
    @trs = @transaction = Transaction.where('id = ?',params[:search].to_i)
 end 


 def aggrigated_summary
   required_params = params.slice(:site_id,:contact_id,:from_date,:to_date)
   @summary =   Item.summary required_params
   @all_sum = 0
   @summary.each{|s| @all_sum += s['t_sum'].to_f}
 end 

 def stock_entries_list
    @stock_entries  = StockEntry.list ({:item_id => parmas[:id]})   
 end

 


end
