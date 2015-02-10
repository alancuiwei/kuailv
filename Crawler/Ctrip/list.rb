# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  

dbh = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306);  
sql = "INSERT INTO `activities` ( `start_city`, `end_city`, `start_time`, `end_time`, `founder`, `f_wechatid`, `f_weiboid`, `remarks`, `f_homepage`) VALUES ( ?,?,?,?,?,?,?,?,?) "
dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  

#保存入数据库同时写入文件备查
fh2 = File.new("persondetail.out", "w")  #创建可写文件流 
fh = File.new("list.out", "w")
$getPageTimes = 0;
$num = 10;
begin
   $getPageTimes +=1;
html=open("http://you.ctrip.com/CommunitySite/Activity/Home/IndexList?page="+$getPageTimes.to_s).read #获取数据列表page调整页码 
doc = Nokogiri::HTML.parse html

#使用此页面http://you.ctrip.com/events/时 需要找到这个div IndexListPage 然后获取其中数据
doc = doc.css("#events_list_content > ul")
doc =doc.to_s
#正则匹配其中url详情，url有重复，只需各执行一个url抓取数据及插入数据库动作即可
i = 0
#doc.scan(/href="(.*)html/).each{
#  |m|#/events/dali31/4127074.
#  #fh.puts"http://you.ctrip.com/#{m[0]}html"
#  fh.puts lll="http://you.ctrip.com/#{m[0]}html"
#} 

urls =doc.scan(/href="(.*)html/)
 i=0
 for url in urls do
 	i=i+1 
   if(i%2==0)	
   else
 	lll="http://you.ctrip.com/#{url[0]}html"

	html=open(lll).read	#获取该页面数据
	charset=Nokogiri::HTML(html).meta_encoding#！有些网页没有定义charset则不适用
	#puts charset 	#打印当前页面编码格式-utf8 否则转码
	html.force_encoding(charset)
	html.encode!("gb2312", :undef => :replace, :replace => "?", :invalid => :replace)
	doc = Nokogiri::HTML.parse html


	#写入个人携程用户名及主页数据-----未完成
	founder = doc.css("#eventusercardview > div > p:nth-child(2) > a") 
	fh2.puts "founder:"  
	#p founder
	fh2.puts founder  
	fh2.puts "\nf_homepage:" 
	f_homepage = (doc.css("#eventusercardview > div > p:nth-child(2) > a")).inner_text
	f_homepage = (doc.css("#eventusercardview > div")).inner_text
	#p f_homepage
	fh2.puts f_homepage  


	#写入城市数据
	cityinfo = doc.css('#eventsummaryinfoview > p.events_place').inner_text.delete('去哪里：')
	citys= cityinfo.split('～') 
	fh2.puts "\nstart_city:"  
	fh2.puts citys[0].lstrip
	fh2.puts "\nend_city:" 
	fh2.puts citys[1].lstrip
	end_city=citys[1].lstrip
	start_city=citys[0].lstrip

	#写入时间数据
	fh2.puts "\nstart_time:" 
	start_time = doc.css("#eventsummaryinfoview > p.events_time > span.littlepadding").inner_text
	fh2.puts start_time 
	fh2.puts "\nend_time:"  
	end_time = doc.css("#eventsummaryinfoview > p.events_time").inner_text
	position =end_time.rindex("共") 
	end_time= end_time[position,3]
	end_time = end_time.delete("共") .delete("天").to_i
	fh2.puts end_time  

	#写入备注数据
	fh2.puts "\nremarks:" 
	remarks = doc.css("body > div.content.cf > div.mainrwd > div.events_infotext > p").inner_text
	fh2.puts remarks.lstrip 

	#写入发起人数据----暂时为空
	fh2.puts "\nf_weiboid:"  
	f_weiboid = "nil"
	fh2.puts f_weiboid  
	fh2.puts "\nf_wechatid:"  
	f_wechatid = "nil"
	fh2.puts f_wechatid 
	#插入数据- 
	stmt.execute(	start_city.to_s,
			end_city.to_s,start_time.to_s,end_time.to_s,
			founder.to_s,f_wechatid.to_s ,
			f_weiboid.to_s,remarks.lstrip.to_s ,lll.to_s
		    )
   end
  end 
end while $getPageTimes < $num
stmt.close if stmt
dbh.close if dbh   
fh.close #关闭文件流
fh2.close #关闭文件流
