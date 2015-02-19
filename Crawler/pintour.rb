# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  
require 'faraday'
require 'excon'


txt = File.open("pintour.txt","w")
txt.puts(Time.now)

def datacheck(title_content)

	if !(title_content.include?"天")
		return false
	end

	if !(title_content.include?"月")
		return false
	end

	if !(title_content.include?"日")
		return false
	end

	return true
end

dbh = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306);  
sql = "INSERT IGNORE INTO `activities` ( `f_homepage`, `start_city`, `end_city`, `start_time`, `end_time`, `remarks`,`created_at`,`beauty`) VALUES ( ?,?,?,?,?,?,?,?) "
dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  

$getPageTimes = 0;
$num = 150;


	conn = Faraday.new(:url => "http://www.pintour.com/") do |faraday|
  	faraday.request  :url_encoded             # form-encode POST params
  	faraday.adapter  :excon  					# make requests with Net::HTTP
  	faraday.options[:timeout] = 200
  	faraday.options[:open_timeout] = 200
	end


begin
	$getPageTimes +=1;
	puts("#{$getPageTimes} / 140")
		
		response = conn.get "/list/0-0-0-0-2-1-s-0_"+$getPageTimes.to_s     # GET http://sushi.com/nigiri/sake.json

#		response = conn.get do |req|
#			req.url "/list/0-0-0-0-2-1-s-0_"+$getPageTimes.to_s
#			req.options[:timeout] = 5
#			req.options[:open_timeout] = 2
#		end

#		html=open("http://www.pintour.com/list/0-0-0-0-2-1-s-0_"+$getPageTimes.to_s).read #获取数据列表page调整页码 

		doc = Nokogiri::HTML(response.body)
#		doc = Nokogiri::HTML.parse html
		thevents = doc.css("body > div.wrap.clearfix > div.main630 > ul > li")

		li_in_onepage = thevents.count

		li_in_onepage.times do |lid|

			thevent = thevents[lid]	

			thetitle = thevent.css("div.mateCon div.timePlace p").text

			txt.puts(thetitle)

			checkresult = datacheck(thetitle)

			if (checkresult) 

				anatitile = thetitle.split()
#				puts anatitile

				#出发城市处理
				start_city = 'all'

				#目的城市处理
				descity_string = anatitile.join
				descity_startpos = descity_string.index"#{anatitile[2]}"
				descity_endpos = descity_string.length
				end_city = descity_string[descity_startpos..descity_endpos - 1]

				#出发日期处理
				ana_startdate = anatitile[0]

				endposition_startmonth = ana_startdate.index'月'
				endposition_startdate = ana_startdate.index'日'

				startmonth = ana_startdate[0..endposition_startmonth-1]
				startday = ana_startdate[endposition_startmonth+1..endposition_startdate-1]

				start_time = Date.strptime("{ 2015-#{startmonth}-#{startday}}", "{ %Y-%m-%d }")


				#回来日期处理
				ana_enddate = anatitile[1]
				endposition_enddate = ana_enddate.index'天'
				dateinterval = ana_enddate[2..endposition_enddate-1]
				end_time = start_time + dateinterval.to_i

				homepage = "http://www.pintour.com/"+thevent.css("div.mateCon h3.mateName a")[0]["href"]

				comments = thevent.css("div.mateCon h3.mateName a").text

				createdate = Time.now

				beautytype = 104

				stmt.execute(homepage.to_s,start_city.to_s,end_city.to_s,start_time.to_s,end_time.to_s,comments.to_s,createdate.to_s,beautytype.to_s)
			end
		
		end

#end while li_in_onepage != 0
end while $getPageTimes < $num

txt.close
stmt.close if stmt
dbh.close if dbh


