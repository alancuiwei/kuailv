# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  
require 'faraday'
require 'excon'


txt = File.open("luguai.txt","w")
txt.puts(Time.now)

def datacheck(title_content)

	if !(title_content.include?"游玩")
		return false
	end

	if !(title_content.include?"去")
		return false
	end

	if !(title_content.include?"天")
		return false
	end

	if !(title_content.include?"-")
		return false
	end

	return true
end

dbh = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306);  
sql = "INSERT IGNORE INTO `activities` ( `f_homepage`, `start_city`, `end_city`, `start_time`, `end_time`, `remarks`,`created_at`,`beauty`) VALUES ( ?,?,?,?,?,?,?,?) "
dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  

$getPageTimes = 0;

	conn = Faraday.new(:url => "http://luguai.com") do |faraday|
  	faraday.request  :url_encoded             # form-encode POST params
  	faraday.adapter  :excon  					# make requests with Net::HTTP
  	faraday.options[:timeout] = 200
  	faraday.options[:open_timeout] = 200
	end

begin
	$getPageTimes +=1;
	puts("#{$getPageTimes} / 600")
		
		response = conn.get "/together/"+$getPageTimes.to_s+".html"     # GET http://sushi.com/nigiri/sake.json

		doc = Nokogiri::HTML(response.body)

		thevents = doc.css("#together_index > div.together-list")

		li_in_onepage = thevents.count

#		puts li_in_onepage

		li_in_onepage.times do |lid|

			thevent = doc.css("div.note_con > div.date_place.clearfix > p")[lid]	

			thetitle = thevent.text

			txt.puts(thetitle)

			checkresult = datacheck(thetitle)

			if (checkresult) 

				anatitile = thetitle.split()

				#出发城市处理
				start_city = anatitile[2]

				#目的城市处理
				descity_startpos = thetitle.index'去'
				descity_endpos = thetitle.index'游玩'
				end_city = thetitle[descity_startpos+2..descity_endpos-2]

				#出发日期处理
				ana_startdate = anatitile[0]

				start_time = Date.strptime("{ #{ana_startdate}}", "{ %Y-%m-%d }")

				#回来日期处理
				startposition_enddate = thetitle.index'游玩 '
				endposition_enddate = thetitle.index' 天'
				dateinterval = thetitle[startposition_enddate+3..endposition_enddate-1]
				end_time = start_time + dateinterval.to_i

				homepage = doc.css("#together_index > div.together-list > div.note_con > h3 > a")[0]["href"]

				comments = doc.css("#together_index > div.together-list > div.note_con > div.content").text

				createdate = Time.now

				beautytype = 103

				stmt.execute(homepage.to_s,start_city.to_s,end_city.to_s,start_time.to_s,end_time.to_s,comments.to_s,createdate.to_s,beautytype.to_s)
			end
		end


end while li_in_onepage != 0

txt.close
stmt.close if stmt
dbh.close if dbh


