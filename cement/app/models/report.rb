class Report < ActiveRecord::Base
  # attr_accessible :title, :body
  audited
  include BaseUtils

end
