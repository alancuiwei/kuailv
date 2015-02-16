# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  
require 'faraday'
require 'excon'


txt = File.open("ctrip.txt","a")


def datacheck(title_content)

	titleana = title_content.split()

	if titleana.count !=5
#		puts "传入参数数目错误"
		return false		
	end	

	if !(titleana[0].include?"出发")
#		puts "出发城市格式不正确"
		return false
	end

	if ((titleana[1].include?"-") || !(titleana[1].include?"月") || !(titleana[1].include?"日"))  
#		puts "出发时间格式不正确 "
		return false
	end

	if (!titleana[3].include?"日") 
#		puts "回来时间包含 － "
		return false
	end

	return true
end



dbh = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306);  
sql = "INSERT IGNORE INTO `activities` ( `f_homepage`, `start_city`, `end_city`, `start_time`, `end_time`, `remarks`,`created_at`,`beauty`) VALUES ( ?,?,?,?,?,?,?,?) "
dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  

$getPageTimes = 0;
#$num = 500;


#	html=open("http://you.ctrip.com/CommunitySite/Activity/Home/IndexList?page="+$getPageTimes.to_s+"&sorttab=eventstab_publish").read #获取数据列表page调整页码 

	conn = Faraday.new(:url => "http://you.ctrip.com") do |faraday|
  	faraday.request  :url_encoded             # form-encode POST params
#  	faraday.response :logger                  # log requests to STDOUT
  	faraday.adapter  :excon  					# make requests with Net::HTTP
	end

begin
	$getPageTimes +=1;

		
	txt.puts("#{$getPageTimes} / 600")
	puts "#{$getPageTimes} / 600"

#		response = conn.get "/CommunitySite/Activity/Home/IndexList?page="+$getPageTimes.to_s+"&sorttab=eventstab_publish"     # GET http://sushi.com/nigiri/sake.json
		response = conn.get do |req|
			req.url "/CommunitySite/Activity/Home/IndexList?page="+$getPageTimes.to_s+"&sorttab=eventstab_publish"
			req.options[:timeout] = 5
			req.options[:open_timeout] = 2
		end

		doc = Nokogiri::HTML(response.body)

		thevents = doc.css("#events_list_content > ul > li")

		li_in_onepage = thevents.count

		li_in_onepage.times do |lid|

			thevent = doc.css("#events_list_content > ul > li")[lid]	

			thetitle = thevent.css("h2 a").text

			txt.puts(thetitle)

			checkresult = datacheck(thetitle)

			if (checkresult)

				anatitile = thetitle.split()

				#出发城市处理
				ana_startcity = anatitile[0]
				endposition_startcity = ana_startcity.index'出发'
				start_city = ana_startcity[0..endposition_startcity-1]

				if start_city == '出发'
					start_city = 'all'
				end

				#目的城市处理
				end_city = anatitile[2]

				#出发日期处理
				ana_startdate = anatitile[1]
				endposition_startmonth = ana_startdate.index'月'
				endposition_startdate = ana_startdate.index'日'

				startmonth = ana_startdate[0..endposition_startmonth-1]
				startday = ana_startdate[endposition_startmonth+1..endposition_startdate-1]

				start_time = Date.strptime("{ 2015-#{startmonth}-#{startday}}", "{ %Y-%m-%d }")

				#回来日期处理
				ana_enddate = anatitile[3]
				endposition_enddate = ana_enddate.index'日'
				dateinterval = ana_enddate[0..endposition_enddate-1]
				end_time = start_time + dateinterval.to_i

				homepage = "http://you.ctrip.com"+thevent.css("h2 a")[0]["href"]
	#			puts homepage

				comments = thevent.css("p").text

				createdate = Time.now

				beautytype = 100

				stmt.execute(homepage.to_s,start_city.to_s,end_city.to_s,start_time.to_s,end_time.to_s,comments.to_s,createdate.to_s,beautytype.to_s)

			end

		end


#	sleep 5

#end while $getPageTimes < $num
end while li_in_onepage != 0

txt.close
stmt.close if stmt
dbh.close if dbh


