
#!/usr/bin/ruby

require 'mysql'

begin
    
    con = Mysql.new 'localhost', 'root', 'zhongren#1234', 'kuailv-production'    

    con.query "DELETE FROM activities WHERE start_time < curdate()"
        
rescue Mysql::Error => e
    puts e    
ensure
    con.close if con
end