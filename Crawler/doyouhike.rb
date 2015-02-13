# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  

dbh = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306);  
sql = "INSERT IGNORE INTO `activities` ( `f_homepage`, `start_city`, `end_city`, `start_time`, `end_time`, `remarks`) VALUES ( ?,?,?,?,?,?) "
dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  

citys = [{name:"上海",code:310000,num:2},{name:"广州",code:440100,num:5},{name:"深圳",code:440300,num:5},{name:"北京",code:110000,num:5}]

citys.each do |city|

	$getPageTimes = 0;
	$num = city[:num];
	$citycode = city[:code];
	$cityname = city[:name];

	begin
		$getPageTimes +=1;

		html=open("http://www.doyouhike.net/event/search?date=all&cid="+$citycode.to_s+"&page="+$getPageTimes.to_s).read

		doc = Nokogiri::HTML.parse html

		thevents = doc.css("#hby_searchBox_body > dl")
		li_in_onepage = thevents.count

		li_in_onepage.times do |lid|

			thevent = thevents[lid]	

			thetitle = thevent.css("dd.des").text

			anatitile = thetitle.split()

			if (anatitile.count == 5)

				#出发城市处理
				start_city = $cityname

				#目的城市处理
				end_city = anatitile[1].split(":")[1]

				#出发日期处理
				start_time_str = anatitile[3].split(":")[1]
				start_time = Date.strptime("{ #{start_time_str}}", "{ %Y-%m-%d }")
				#回来日期处理
				ana_enddate = anatitile[4]
				endposition_enddate = ana_enddate.index'天'
				dateinterval = ana_enddate[1..endposition_enddate-1]
				end_time = start_time + dateinterval.to_i
				
				homepage = "http://www.doyouhike.net/"+thevent.css("dt > a")[0]["href"]
				
				comments = thevent.css("dt > a")[0].text
				
				stmt.execute(homepage.to_s,start_city.to_s,end_city.to_s,start_time.to_s,end_time.to_s,comments.to_s)

			end

		end
		
	end while $getPageTimes < $num
end

stmt.close if stmt
dbh.close if dbh
