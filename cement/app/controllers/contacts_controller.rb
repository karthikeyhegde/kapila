require 'axlsx' 
class ContactsController < ApplicationController
respond_to :json, :html

 def index

    ord_column = 'name,subname '
    ord =  'ASC'
    if !params[:ord].blank?
      ord_column =  params[:ord].split('_')[0]
      ord =  params[:ord].split('_')[1]
    end 
    if !params[:condn].blank? || params[:condn] != "all"
      condn =  " regular = 1 " if params[:condn] == 'regular'
      condn = " supplier = 1 " if params[:condn] == 'supplier'
      condn = " regular = 0 "  if params[:condn] == 'nonregular'
      @contacts = Contact.where(condn).order(ord_column+ord)

    else 
      params[:condn] = 'all'
      @contacts =  Contact.order(ord_column+ord)
      
    end  
  end

   

 def show
 end

 def new
   @contact = Contact.new
   @form_method = 'post'
   #respond_to do |format|

    # format.js { render :layout=>false }
   #end
 end

 def create
   @contact = Contact.new(params[:contact])
   current_user =  @current_user
   @contact.save!
   redirect_to :action =>'index'

 end

 def add_txn
  @contact = Contact.new
  respond_to do |format|
      format.js {render layout: false}
   end 
 end
  
 def ajax_create

   @contact = Contact.new(params[:contact])
   begin 
    current_user =  @current_user
    @contact.save!
   rescue Exception => e
    p "error occured"
    flash[:error] = e.to_s
   end  
   respond_to do |format|
      format.js {render layout: false}
   end 

 end 

 def edit
   
   @contact = Contact.find(params[:id])
   @form_method = "update"
 end

 def update
  @contact = Contact.find(params[:id])
  @contact.update_attributes(params[:contact])
  redirect_to :action => 'index'
 end

 def quick_edit 
   @contacts = Contact.order("name,subname")
 end 

 def quick_update
  begin
    hsh = {}
    hsh[params[:name]] = params[:value]
    id = params[:pk].to_i
    @c = Contact.find(id)
    @c.update_attributes(hsh)
     render :json => {"message" => "Success"}
  rescue Exception => e
    p e   
  end
 end

 
 def all_edit
 end

 def all_update
 end 

 def search_list
    @contacts.where("name like '%")
 end 

 def destroy
 end

 def remove
   Contact.find(params[:id]).destroy
   redirect_to :action => 'index'
 end

 def search_names
   contacts = Contact.trns_search(params[:str])
   respond_to do |format|
      format.json {render :json => contacts.to_json}
   end  
 end 


 def window_list
   p "PARMS"
   p params
   if params[:type] == 'stock'
     @contacts = Contact.where("supplier = true").order("name,subname") 
   else
     @contacts = Contact.order("name,subname")
   end    
   respond_to do |format|
      format.js {render layout: false}
   end 
 end 

 def report_page
  p "HERES"
    @show_val =  params[:show_val].blank? ? 'trs' : params[:show_val]
    p "SHOW VAL"
    p params[:show_val]
    p @show_val
    @contact = Contact.find(params[:id])

    @report = Report.new
    @transactions = @trs = @contact.rep_trans  if @show_val == 'trs'
    if @show_val == 'itms'
       @txn_items = @contact.rep_items
       p "@TXN ITM"
       p @txn_items
       @item_aggr = @contact.aggr_items
    end  
    @payments =  @contact.rep_payments if @show_val == 'pays'
    p flash[:notice]
 end 


 def reports
   @reports = Report.new
   if params[:commit] == 'Get Excel'
     redirect_to :action => 'excel_export',  :from_date => params[:from_date], :to_date => params[:to_date], :id => params[:id]
     return
   end 
   id = params[:id]
   from_date = ( params[:from_date].blank? ?  '2000-01-01':params[:from_date] )
   to_date =  ( params[:to_date].blank? ? '2100-01-01' : params[:to_date] )
   f_date = DateTime.parse(from_date).strftime('%Y-%m-%d %H:%M')
   t_date = DateTime.parse(to_date).strftime('%Y-%m-%d %H:%M')

   @contact = Contact.find(id)
   @transactions = Transaction.where('contact_id = ?  and on_date between ? and ?',id,f_date,t_date).order('on_date desc,created_at ASC ')
   respond_to do |format|
      format.js {render layout: false}
   end 

 end 



 def filter
    @filter = true
    @report =  Report.create_with_params params[:report] if params[:id].blank? 
    if params[:report].blank? and !params[:id].blank? 
       @report = Report.find(params[:id])
     end 
   @contact = Contact.find(params[:contact_id])
   @show_val =  params[:show_val].blank? ? 'trs' : params[:show_val]
    p "SHOW VAL"
    p @show_val
   case @show_val
   when 'itms'
       @txn_items , @item_aggr = @report.item_contact_filter
   when 'pays'
       @payments = @report.payment_contact_filter 
   else       
     @trs = @transactions = @report.contact_filter
   end  

   if params[:commit] == "Save as"
       if !params[:id].blank?
           rp = Report.find(params[:id])
           rp.report_type = 'ALL CONTACT'  if params[:all_contacts] == 'true'  
           rp.update_attributes!(params[:report])

        else
           @report.tag="contact_filter"
           @report.report_type = 'ALL CONTACT' if params[:all_contacts] == 'true'
           @report.tag = 'contact_filter'
           @report.is_saved = true  
           @report.save!    
       end 
     end 
   respond_to do |format|
      format.js {render 'reports', layout: false} if @show_val == 'trs'
      format.js { render 'item_reports' ,layout: false} if @show_val == 'itms'
      format.js { render 'payment_reports' ,layout: false} if @show_val == 'pays'
   end 
end
 
 def save_filter
 end 

 def show_filter
   @filter = true
   @report = Report.find(params[:id].to_i)
   @trs = @transactions = @report.contact_filter 
   @contact =  Contact.find(params[:contact_id].to_i)
   p "FOLTER SIZE"
   p  @transactions.size
   @transactions.each{|a|
    p "-- #{a.id}+ -- #{a.contact_id}"
   }
   respond_to do |format|
      format.js {render 'reports', layout: false}
   end
 end 



 def excel_export
  id = params[:id]
   from_date = ( params[:from_date].blank? ?  '2000-01-01':params[:from_date] )
   to_date =  ( params[:to_date].blank? ? '2100-01-01' : params[:to_date] )
   f_date = DateTime.parse(from_date).strftime('%Y-%m-%d %H:%M')
   t_date = DateTime.parse(to_date).strftime('%Y-%m-%d %H:%M')

   @contact = Contact.find(id)
   @transactions = Transaction.where('contact_id = ?  and on_date between ? and ?',id,f_date,t_date).order('on_date,created_at')
 
   
    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Transactions") do |wb|
     # define your regular styles
      styles = wb.styles
      title = styles.add_style(:sz => 14, :b => true,:bg_color => '00FFFF')

      default = styles.add_style(:border => Axlsx::STYLE_THIN_BORDER)
      money = styles.add_style(:format_code => '##,##,##0.##', 
                           :border => Axlsx::STYLE_THIN_BORDER)
      percent = styles.add_style(:num_fmt => Axlsx::NUM_FMT_PERCENT,   
                             :border => Axlsx::STYLE_THIN_BORDER)

      wb.add_row  ['Contact:',@contact.name_subname]
      report_txt = ''
      if params[:from_date].blank? and params[:to_date].blank?
        report_txt += 'Report of all transactions.'
       else  
        report_txt += 'Transactions -'
        if !params[:from_date].blank? 
             report_txt += 'From '+params[:from_date] 
        end
         if !params[:to_date].blank? 
            report_txt += 'up to '+params[:to_date] 
        end
             
      end

      wb.add_row  [report_txt]
      wb.add_row ['Current Account Balance', @contact.balance]
      wb.add_row ['']
      count = 1
      c = 0      
      @transactions.each{|t|
        s = t.buyback == 1? '(Vaapas)':''
        wb.add_row [ 'Trans# '+count.to_s+' '+s, 'Date : '+ t.on_date.to_s, '', 'Site',t.site_name], :style => title
        wb.add_row ['']
        if t.trans_type == 'payment'
          wb.add_row [ t.tofrom + ' '+t.payment_type+' Payment:', 'Rs '+t.payment_amount_s]
          wb.add_row ['Account Balanace:', 'Rs '+t.contact_balance.to_s]
          wb.add_row ['Payment Info:', t.payment_note] ,:widths => [:ignore,:ignore,50]
          wb.add_row ['Note:', t.descri] ,:widths => [:ignore,:ignore,50]
        else  
          wb.add_row ['Item#', 'Item','Description','Price','Quantity','Amount'], :b =>true
          c = 1
          t.txn_items.each{|ti|
           wb.add_row [ c.to_s, ti.item.name,ti.item_descri,ti.price.to_s,ti.number.to_s,ti.amount.to_s] ,:widths => [:ignore,:ignore,30,30,:auto,:auto,:auto]
           c += 1
          }
          c += 1
        wb.add_row [c.to_s,'Vehicle Charges','','','',t.vehicle_charges]
        wb.add_row [(c+1).to_s,'Hamaali','','','',t.hamaali]
        wb.add_row ['','','','','Total Amount',t.amount.to_s]
        wb.add_row ['','','','', t.tofrom + ' '+t.payment_type+' Payment:', 'Rs '+t.payment_amount_s]
        wb.add_row ['','','','', 'Account Balanace:', 'Rs '+t.contact_balance.to_s]
        wb.add_row [ 'Payment Info:', t.payment_note],:widths => [:ignore,:ignore,50]
        wb.add_row ['Note:', t.descri],:widths => [:ignore,:ignore,50]
        wb.add_row ['']

        end  
        count += 1
      }

      time = DateTime.now.to_s.sub(':','')
      #p.serialize @contact.name_subname_underscore+'_transactions_'+time+'.xlsx'
      send_data p.to_stream.read, type: "application/xlsx", filename: @contact.name_subname_underscore+'_transactions_'+time+'.xlsx'
    end


 end 

 

end
