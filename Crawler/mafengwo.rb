# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  
require 'faraday'
require 'excon'


txt = File.open("mafengwo.txt","w")
txt.puts(Time.now)

def datacheck(title_content)

	if (!title_content.include?"日") 
		return false
	end

	if (!title_content.include?"月") 
		return false
	end

	if (title_content.include?"00") 
		return false
	end

	return true
end

dbh = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306);  
sql = "INSERT IGNORE INTO `activities` ( `f_homepage`, `start_city`, `end_city`, `start_time`, `remarks`,`created_at`,`beauty`) VALUES ( ?,?,?,?,?,?,?) "
dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  

$getPageTimes = 0;
$num = 400;

=begin
	conn = Faraday.new(:url => "http://www.mafengwo.cn/") do |faraday|
  	faraday.request  :url_encoded             # form-encode POST params
  	faraday.adapter  :excon  					# make requests with Net::HTTP
  	faraday.options[:timeout] = 200
  	faraday.options[:open_timeout] = 200
	end
=end

begin
	$getPageTimes +=1;
	$getPageTimes_string = $getPageTimes*15
	puts("#{$getPageTimes} / 400")

	html=open("http://www.mafengwo.cn/together/?action=turnpage&torder=new&start="+$getPageTimes_string.to_s).read #获取数据列表page调整页码 

	doc = Nokogiri::HTML.parse html

		
#		response = conn.get "/together/?action=turnpage&torder=new&start="+$getPageTimes_string.to_s     # GET http://sushi.com/nigiri/sake.json

#		doc = Nokogiri::HTML(response.body)

		thevents = doc.css("body > form > div > div.l_con > div.alllist > div.list > ul > li")

		li_in_onepage = thevents.count

		li_in_onepage.times do |lid|

			thevent = thevents[lid]	

			checkresult = datacheck(thevent.css("div.w4").text)

			if (checkresult)

					#出发城市处理
				start_city = thevent.css("div.w2").text
				puts start_city

					#目的城市处理
				end_city = thevent.css("div.w3 > span > a").text
				puts end_city

					#出发日期处理
				ana_startdate = thevent.css("div.w4").text
				puts ana_startdate


				endposition_startmonth = ana_startdate.index'月'
				endposition_startdate = ana_startdate.index'日'

				startmonth = ana_startdate[0..endposition_startmonth-1]
				startday = ana_startdate[endposition_startmonth+1..endposition_startdate-1]

				start_time = Date.strptime("{ 2015-#{startmonth}-#{startday}}", "{ %Y-%m-%d }")


				homepage = "http://www.mafengwo.cn"+thevent.css("div.w1 > div.r_tit > div.tit > a")[0]["href"]

				comments = thevent.css("div.w1 > div.r_tit > div.tit > a").text

				createdate = Time.now

				beautytype = 105

				stmt.execute(homepage.to_s,start_city.to_s,end_city.to_s,start_time.to_s,comments.to_s,createdate.to_s,beautytype.to_s)
			end
		
		end

#end while li_in_onepage != 0
end while $getPageTimes < $num

txt.close
stmt.close if stmt
dbh.close if dbh


