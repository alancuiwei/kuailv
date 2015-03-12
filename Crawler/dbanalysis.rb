# encoding : utf-8

require 'mysql2'

begin
    
    con = Mysql.new 'localhost', 'root', '123456', 'kuailv-development'    

    events = con.query "SELECT * FROM activities"

    events.each_hash do |event|

    	if (event['end_city'] == '丽江')
    		puts "++丽江++"
    	end

    end


        
rescue Mysql::Error => e
    puts e    
ensure
    con.close if con
end