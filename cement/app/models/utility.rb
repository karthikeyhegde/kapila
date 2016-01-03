class Utility

	def self.rep_aggrigation
		sql =      " select sum(if(txn.buyback = 1, txn.amount * -1, txn.amount)) as t_amount, "
        sql <<     " sum(if(txn.buyback = 1, txn.hamaali * -1, txn.hamaali)) as t_hamaali, "
        sql <<     " sum(if(txn.buyback = 1, txn.vehicle_charges * -1, txn.vehicle_charges)) as t_vehicle_charges, "
        sql <<     " sum(if(txn.buyback = 1, txn.other_charges_amount * -1, txn.other_charges_amount)) as t_other_charges_amount,"
        sql <<     " sum(if(txn.recieved != 1, txn.payment_amount * -1, txn.payment_amount)) as t_payment_amount, "
        sql <<     " sum(if(txn.buyback = 1, txn.discount * -1, txn.discount)) as t_discount "
        sql <<     " from transactions txn "
        agr_transaction = Transaction.find_by_sql(sql)
        return agr_transaction
	end	

     


    def self.indian_number(number) 
      if number 
        string = number.to_s.split('.')
        number = string[0].gsub(/(\d+)(\d{3})$/){

          p = $2;"#{$1.reverse.gsub(/(\d{2})/,'\1,').reverse},#{p}"
        } 
        number = number.gsub(/^,/, '') + '.' + string[1] if string[1] 
        # remove leading comma 
        number = number[1..-1] if number[0] == 44 or number[0] == ','
      end 
      "#{number}" 
    end

    def self.mysql_date dates
      da =  dates.to_s.split('-')
      return da[2]+'-'+da[1]+'-'+da[0]
    end 


    
end	