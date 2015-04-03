class Item < ActiveRecord::Base
  # attr_accessible :title, :body

  has_many :txn_items


  include BaseUtils



  def list_by_contacts
  end
  
  def get_by_number_of_items
  end	

  def rep_ixnitems sdate = nil, edate=nil
     sdate = "1999-01-01" if sdate.nil?
     edate = "2100-01-01" if edate.nil?
     sql_str =  " select ti.*,t.on_date from txn_items ti , transactions t where ti.transaction_id = t.id "
     sql_str << " and t.on_date  between '#{sdate}' and '#{edate}' " 
     sql_str << " and item_id = #{self.id} order by t.on_date desc "
     p "LL"
     p sql_str
     TxnItem.find_by_sql(sql_str)
  end	


  def self.picklist
     arr = []
     self.order("name, description").each{|a|

      p_name =  ( a.description.blank? ? a.name : a.name+", "+a.description)
      arr << [p_name, a.id]
     }
     return arr
  end  


end
