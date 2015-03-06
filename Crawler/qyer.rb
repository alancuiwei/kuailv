# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  
require 'faraday'
require 'excon'


dbh = Mysql.real_connect("localhost","root","123456","kuailv-development",3306);  
sql = "INSERT IGNORE INTO `activities` ( `f_homepage`, `start_city`, `end_city`, `start_time`, `end_time`, `remarks`,`created_at`,`beauty`) VALUES ( ?,?,?,?,?,?,?,?) "
dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  

$getPageTimes = 0;

txt = File.open("qyer.txt","w")
txt.puts(Time.now)

conn = Faraday.new(:url => "http://bbs.qyer.com") do |faraday|
	faraday.request  :url_encoded             # form-encode POST params
	faraday.adapter  :excon  					# make requests with Net::HTTP
	faraday.options[:timeout] = 200
	faraday.options[:open_timeout] = 200
end

begin
	$getPageTimes +=1;

	response = conn.get "/forum-2-"+$getPageTimes.to_s+".html"     # GET http://sushi.com/nigiri/sake.json

	doc = Nokogiri::HTML(response.body)

	thevents = doc.css("#moderate > ul > li")

	li_in_onepage = thevents.count

	li_in_onepage = 1

	li_in_onepage.times do |lid|

		thevent = thevents[lid]	

		thetitle = thevent.css("h3 a").text

		#帖子的链接地址 
		$thelink = thevent.css("h3 a")[0]["href"]
#		puts $thelink

		sonresponse = conn.get $thelink.to_s

		sondoc = Nokogiri::HTML(sonresponse.body)

		sonevents = sondoc.css("div.bbs_titboxs > div.bbs_titbox > h1").text

#		sonevents = sondoc.css("#postlist > div.bbs_postview > div.bbs_txtbox > table > tbody > tr > td > p").text

#		sonevents = sondoc.css("#postmessage_10737126 > table > tbody > tr > td > p").text

#		puts sonevents

	#	sonli_in_onepage = sonevents.count

	#	puts sonli_in_onepage

	end

end while li_in_onepage != 0

txt.close
stmt.close if stmt
dbh.close if dbh


