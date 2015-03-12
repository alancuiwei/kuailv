# encoding : utf-8

require 'mysql'

begin
    
    con = Mysql.init
    con.options(Mysql::SET_CHARSET_NAME, 'utf-8')
    con = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306); 
    con.query("SET NAMES utf8")

    events = con.query "SELECT * FROM activitiesbackup"

    lijiang = 0
    lasa = 0
    nanjing = 0

    events.each_hash do |event|

    	if (event['end_city'].force_encoding("utf-8").include?"丽江")
    		lijiang +=1
    	end

        if (event['end_city'].force_encoding("utf-8").include?"拉萨")
            lasa +=1
        end

        if (event['end_city'].force_encoding("utf-8").include?"南京")
            nanjing +=1
        end

    end

    puts "丽江 ＝ #{lijiang}"
    puts "拉萨 ＝ #{lasa}"
    puts "南京 ＝ #{nanjing}"


        
rescue Mysql::Error => e
    puts e    
ensure
    con.close if con
end