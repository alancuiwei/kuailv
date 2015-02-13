# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  

dbh = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306);  
sql = "INSERT IGNORE INTO `activities` ( `f_homepage`, `start_city`, `end_city`, `start_time`, `end_time`, `remarks`) VALUES ( ?,?,?,?,?,?) "
dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  

$getPageTimes = 0;
$num = 10;
begin
	$getPageTimes +=1;
	html=open("http://you.ctrip.com/CommunitySite/Activity/Home/IndexList?page="+$getPageTimes.to_s+"&sorttab=eventstab_publish").read #获取数据列表page调整页码 

	doc = Nokogiri::HTML.parse html

	thevents = doc.css("#events_list_content > ul > li")
	li_in_onepage = thevents.count

	li_in_onepage.times do |lid|

		thevent = doc.css("#events_list_content > ul > li")[lid]	

		thetitle = thevent.css("h2 a").text
		puts thetitle

		anatitile = thetitle.split()

		#出发城市处理
		ana_startcity = anatitile[0]
		endposition_startcity = ana_startcity.index'出发'
		start_city = ana_startcity[0..endposition_startcity-1]

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

		comments = thevent.css("p").text

		stmt.execute(homepage.to_s,start_city.to_s,end_city.to_s,start_time.to_s,end_time.to_s,comments.to_s)

	end
end while $getPageTimes < $num

stmt.close if stmt
dbh.close if dbh
