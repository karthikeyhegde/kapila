
class StockEntry < ActiveRecord::Base
    attr_accessor :diff
    belongs_to :item
    belongs_to    :contact


    before_save :calc_entry_stock
    after_save  :calc_item_current_stock
    after_update :update_calc_stock
    after_destroy :destroy_stock_update


    def calc_item_current_stock
      se_numbers =  (is_return == 1? (self.numbers * -1) : self.numbers)
   	  self.item.current_stock = self.item.current_stock + se_numbers
   	  self.item.save!
    end

    def calc_entry_stock
       se_numbers =  (is_return == 1? (self.numbers * -1) : self.numbers)	
   	   self.item_stock = self.item.current_stock + se_numbers	   
    end	

    def update_calc_stock  
	      se_numbers =  (is_return == 1? (self.numbers * -1) : self.numbers)
	      se_numbers_was =  (self.is_return_was == 1? (self.numbers_was * -1) : self.numbers_was) 
	      diff = se_numbers.to_i - se_numbers_was.to_i
	   	  stock_update diff  if diff != 0
    end	

    def destroy_stock_update
      stock_upadate(self.numbers * -1)
    end  

    def stock_upadate diff
	    self.item.current_stock = self.item.current_stock + diff
   	  self.item.save!
   	  mysql_date = Utility.mysql_date on_date 
      sql =  "  UPDATE stock_entries set item_stock =  item_stock + #{diff} "
      sql << " where item_id = #{self.item_id} and ( on_date > '#{mysql_date}' OR (on_date = '#{mysql_date}' and created_at > '#{self.created_at}' ))"
      ActiveRecord::Base.connection.execute(sql)
    end	


end	