#!/usr/bin/env ruby
require File.expand_path( '../../config/boot',__FILE__)
require  File.expand_path( '../../config/environment',__FILE__)

require 'csv'

csv_text = File.read('data/vas_items.csv')
csv = CSV.parse(csv_text)
p csv.count
str = ''
csv.each do |row|
  if !row[0].blank?
  	  str = "'"+row[0]+"',"
  	  
  end
  	
  p str  
end