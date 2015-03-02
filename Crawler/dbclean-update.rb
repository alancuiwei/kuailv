
#!/usr/bin/ruby

require 'mysql'

begin
    
    con = Mysql.new 'localhost', 'root', '123456', 'kuailv-development'    

    con.query "INSERT IGNORE INTO activitiesbackup \ 
    			SELECT * FROM activities"
        
rescue Mysql::Error => e
    puts e    
ensure
    con.close if con
end