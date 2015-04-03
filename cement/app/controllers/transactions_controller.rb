class TransactionsController < ApplicationController
  @@available_action = ['new_sale','new_return','new_payment']
 
 def index
  sort_column = params[:sort_colum] || 'on_date'
  sort_order = params[:sort_order]  || "DESC"
  page_size = params[:page_size] || 20
  offset = params[:offset] || 0

  
   @trs = Transaction.order("#{sort_column} #{sort_order}, created_at DESC")
 end

 def show
 end

 def new
   @trans = Transaction.new
   @form_method = 'post'
   render :action => params[:tx_type] if  @@available_action.include?(params[:tx_type])
 end

 def new_sale
 end
 
 def new_return
 end 

 def new_payment
 end 

 def edit
   @trans = Transaction.find(params[:id])
   @contact_name = @trans.contact.name.to_s+" "+@trans.contact.subname.to_s
   @site_name = (@trans.site.blank? ?  "":@trans.site.name)
   @form_method = 'put '
 end

 def create
  p "PARAMS"
  p params
    @trans = Transaction.new(params[:transaction])
    @trans.created_by = @auser.id
    params[:txn_items].each{ |key,val|
     item_params = val
     unless ( item_params[:item_id].blank? || item_params[:item_id].to_i == 0) && item_params[:item_descri].blank? 
      ti = TxnItem.new(item_params)
      ti.contact_id = params[:transaction][:contact_id]
      ti.amount = ti.calculate_amount
      @trans.txn_items << ti
     end 
    }

     site_param = params[:txn][:site]
     if !site_param.blank? and  site_param.length > 3
       site = Site.find_by_name(site_param)
       if site == nil
         site = Site.new
         site.name = site_param
         site.save!
       end 

       @trans.site = site
     end
   begin
      @trans.save!
      @trs = Transaction.all
      flash[:notice] = 'Transaction# '+@trans.id.to_s+' added Successfully !'
      flash.keep(:notice)
      render js: "window.location.pathname='#{transactions_path}'"
    rescue Exception => e
     p e.to_s
     @serr = e.to_s
     respond_to do |format|
       format.js {render layout: false}

     end  
   end
    

    
    #redirect_to :action => 'index'

  end

 def update
   @trans = Transaction.find(params[:id])
    txn_ids = []
   params[:txn_items].each{|key,val|

      id = key.to_i
      txn_ids << id
      
     
      if id.to_i < 1000 
        ti = TxnItem.new(val)
        ti.created_by = @auser.id
        ti.calculate_amount
        ti.save!
        @trans.txn_items <<   ti
        txn_ids << ti.id
      else
         old_txi = TxnItem.find(id)  

         if old_txi.item_id != val[:item_id].to_i || old_txi.price != val[:price].to_f || old_txi.number != val[:number].to_i
           val[:updated_by] = @auser.id
           val[:amount] = val[:price].to_f * val[:number].to_i
           old_txi.update_attributes(val)          
         end          
      end 
    
    } unless  params[:txn_items].blank?

      @trans.txn_items.each{|txn|
        txn.destroy if  !txn_ids.include?(txn.id)
      }


     site_param = params[:txn][:site]
     p "SITE PARAM"

     if !site_param.blank? and  site_param.length > 3
       site = Site.find_by_name(site_param)
   
       if site == nil
         site = Site.new
         site.name = site_param
         site.save!
       end 

           p "SITE"
       p site.name
       p site.id

       p "2 nd SITE ID"
       params[:transaction][:site_id] = site.id

     end


    p "RARAM"
    p params[:transaction]
    begin  
     p "CALLING 1"
     @trans.skip_updator = true
     @trans.save!
     #@trans(params[:transaction])
     p "CALLING 2"
     @trans.skip_updator = false
     @trans.update_attributes(params[:transaction])


     render js: "window.location.pathname='#{transactions_path}'"
    rescue Exception => e
     p e.to_s
     @serr = e.to_s
       respond_to do |format|
         format.js {render layout: false}

       end  
    end
  
 end

 def destroy
 end

def remove
   Transaction.find(params[:id]).destroy
   redirect_to :action => 'index'
 end

 def add_item_row
   row_no = params[:no]
   @row_no = row_no.to_i + 1
   @txn_item = TxnItem.new 
   respond_to do |format|
     format.js {render layout: false}
   end
 end 

 def search_contact
   contacts = Contact.trns_search(params[:str])
   respond_to do |format|
      format.json {render layout: false}
   end   

 end 



end
