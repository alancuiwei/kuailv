# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  


txt = File.open("yueban.txt","w")
txt.puts(Time.now)

dbh = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306);  
sql = "INSERT IGNORE INTO `activities` ( `f_homepage`, `start_city`, `end_city`, `start_time`, `end_time`, `remarks`,`created_at`,`beauty`,`qq`) VALUES ( ?,?,?,?,?,?,?,?,?) "
dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  

$getPageTimes = 0;
#$num = 960;

begin

	html=open("http://yueban.com/menu/"+$getPageTimes.to_s).read #获取数据列表page调整页码 

	doc = Nokogiri::HTML.parse html

	thevents = doc.css("#topicList > div.topic-wrapper > div.inner > div.topic-list > div.topic")
	li_in_onepage = thevents.count
#	puts li_in_onepage
#	li_in_onepage = 20

	li_in_onepage.times do |lid|

		thevent = thevents[lid]	

		thetitle = thevent.css("div.media-body > div.section > div.section-header > a").text

		txt.puts(thetitle)

		theothers = thevent.css("div.media-body > div.section > div.section-header > p > span").text

		txt.puts(theothers)

		anatitile = thetitle.split()

		if (anatitile.count == 3)

			#出发城市处理
			ana_startcity = anatitile[1]
			endposition_startcity = ana_startcity.index'出发'
			start_city = ana_startcity[0..endposition_startcity-1]

			#目的城市处理
			ana_end_city = anatitile[2]
			endcitylength = ana_end_city.length
			end_city = ana_end_city[3..endcitylength]

			#出发日期处理
			ana_startdate = anatitile[0]
			endposition_startmonth = ana_startdate.index'月'
			endposition_startdate = ana_startdate.index'日'

			startmonth = ana_startdate[1..endposition_startmonth-1]
			startday = ana_startdate[endposition_startmonth+1..endposition_startdate-1]

			start_time = Date.strptime("{ 2015-#{startmonth}-#{startday}}", "{ %Y-%m-%d }")

			#回来日期处理

			if theothers.include?"天"
			endposition_enddate = theothers.index'天'
			dateinterval = theothers[0..endposition_enddate-1]
			end_time = start_time + dateinterval.to_i
			end


			if theothers.include?"QQ"
			endposition_qq = theothers.index'QQ'
			qq = theothers[endposition_qq+3,theothers.length]
			end


			homepage = "http://yueban.com"+thevent.css("div.media-body > div.section > div.section-header > a")[0]["href"]

			comments = thevent.css("div.media-body > div.section > div.section-content").text

			createdate = Time.now

			beautytype = 102

			stmt.execute(homepage.to_s,start_city.to_s,end_city.to_s,start_time.to_s,end_time.to_s,comments.to_s,createdate.to_s,beautytype.to_s,qq.to_s)

		end

	end

	$getPageTimes +=20;
	txt.puts("#{$getPageTimes} / 1000")
#	puts "#{$getPageTimes} / 1000"

#end while $getPageTimes < $num
end while li_in_onepage != 0


txt.close
stmt.close if stmt
dbh.close if dbh
