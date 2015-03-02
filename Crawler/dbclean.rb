
#!/usr/bin/ruby

require 'mysql'

begin
    
    con = Mysql.new 'localhost', 'root', 'zhongren#1234', 'kuailv-production'    

#    con.query "CREATE TABLE activitiesbackup \ 
#    			SELECT * FROM activities"


    con.query "INSERT IGNORE INTO activitiesbackup \ 
    			SELECT * FROM activities"

    con.query "DELETE FROM activities WHERE start_time < curdate()"


        
rescue Mysql::Error => e
    puts e    
ensure
    con.close if con
end