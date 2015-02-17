#!/usr/bin/ruby

require 'mysql'
require 'date'

begin

    txt = File.open("analysis.txt","a")
    txt.puts(Time.now)
    con = Mysql.new 'localhost', 'root', 'zhongren#1234', 'kuailv-production'    

    @querycondition = "SELECT * FROM activities WHERE ID IN (1,2,3,4,5,6,7,8,9,10)"
    rs = con.query @querycondition
    # 计算数据库中所有的记录
    totalnum = rs.num_rows
    
#    puts "There are #{totalnum} rows in the activities set"
#	txt.puts("数据库中今天共有 #{totalnum} 条记录。")

    l1_successful_matched = 0
    l1_failed_matched = 0
#    user_created_num = 0


	rs.each_hash do |activity|

		target_start_city = activity['start_city']
        target_end_city   = activity['end_city']
        target_start_time= activity['start_time']
        target_start_time_1 = Date.strptime("{ #{target_start_time} }", "{ %Y-%m-%d }")-7
        target_start_time_2 = Date.strptime("{ #{target_start_time} }", "{ %Y-%m-%d }")+7

        puts target_start_city
        puts target_end_city
        puts target_start_time

        @l1querycondition = "select * from `kuailv-production`.`activities` where `start_city` LIKE '%#{target_start_city}%' AND `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time_1}' AND '#{target_start_time_2}'"
        l1_resultevents = con.query @l1querycondition

        puts l1_resultevents.num_rows

        if l1_resultevents.num_rows ==1
            l1_failed_matched = l1_failed_matched+1
        else
            l1_successful_matched = l1_successful_matched+1
        end
	end

#	puts l1_successful_matched
#	puts l1_failed_matched
#	puts totalnum


    con.query "DELETE FROM activities WHERE start_time < curdate()"
        
rescue Mysql::Error => e
    puts e    
ensure
    con.close if con
    txt.close
end