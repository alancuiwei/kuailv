#!/usr/bin/ruby

require 'mysql'
require 'date'

begin

    txt = File.open("analysis.txt","a")
    txt.puts(Time.now)
    con = Mysql.new 'localhost', 'root', '123456', 'kuailv-development'    

    @querycondition = "SELECT * FROM activities WHERE Id IN (24268)"
    rs = con.query @querycondition
    # 计算数据库中所有的记录
    totalnum = rs.num_rows
    
    puts "There are #{totalnum} rows in the activities set"
	txt.puts("数据库中今天共有 #{totalnum} 条记录。")

    l1_successful_matched = 0
    l1_failed_matched = 0

    l2_successful_matched = 0
    l2_failed_matched = 0

    l3_successful_matched = 0
    l3_failed_matched = 0

	rs.each_hash do |activity|

		target_start_city = activity['start_city']
        target_end_city   = activity['end_city']
        target_start_time= activity['start_time']
        target_start_time_1 = Date.strptime("{ #{target_start_time} }", "{ %Y-%m-%d }")-7
        target_start_time_2 = Date.strptime("{ #{target_start_time} }", "{ %Y-%m-%d }")+7

        @l1querycondition = "select * from `kuailv-development`.`activities` where `start_city` LIKE '%#{target_start_city}%' AND `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time_1}' AND '#{target_start_time_2}'"
        l1_resultevents = con.query @l1querycondition

        puts l1_resultevents.num_rows

=begin		
        if l1_resultevents.num_rows ==1
            l1_failed_matched = l1_failed_matched+1
        else
            l1_successful_matched = l1_successful_matched+1
        end

        if l3_resultevents.num_rows ==1
            l3_failed_matched = l3_failed_matched+1
        else
            l3_successful_matched = l3_successful_matched+1
        end
=end      
	end

	l1num = l1_successful_matched
    l3num = l3_successful_matched  

#    puts l1num
#    puts l3num

    con.query "DELETE FROM activities WHERE start_time < curdate()"
        
rescue Mysql::Error => e
    puts e    
ensure
    con.close if con
    txt.close
end