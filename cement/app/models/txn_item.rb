class TxnItem < ActiveRecord::Base
	belongs_to :transaction
	belongs_to :item
    belongs_to :contact

	#before_save :calculate_amount
    validate :all_validation
    include BaseUtils


    def all_validation
      errors.add(:item, "Select item or enter description ")  if  item_descri.blank? and item.blank?
      errors.add(:number, "Enter the quantity/no of items")   if number == 0
    end
        
	def calculate_amount
		self.amount = number.to_i * price.to_f
	end	

   

  class << self

    def list_by_items ids, sdate, edate
    	self.where("item_id in (?)", ids)
    end
    
    def list_by_contacts ids, sdate, edate
    	self.where(" contact_id in (?)", ids)
    end

    def list_by_sites ids, sdate, edate
    	self.where(" site_id in (?)", ids)
    end


    def aggrigate_on_item sdate, edate
    	self.find_by_sql("select count(id)")
    end 	

    def aggrigate_on_contact sdate, edate
    end
    
    def aggrigate_on_number sdate, edate
    end 	

  end

end
