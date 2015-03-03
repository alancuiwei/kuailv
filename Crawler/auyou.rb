# encoding : utf-8
require 'nokogiri'
require 'open-uri'
require "mysql"  


dbh = Mysql.real_connect("localhost","root","zhongren#1234","kuailv-production",3306);  
sql = "INSERT IGNORE INTO `activities` ( `f_homepage`, `start_city`, `end_city`, `start_time`, `end_time`, `created_at`,`beauty`) VALUES ( ?,?,?,?,?,?,?) "

dbh.query("SET NAMES utf8")
stmt=dbh.prepare(sql)  


citys = [{name:"丽江",code:"lijiang"},{name:"西藏",code:"xizang"},{name:"北京",code:"beijing"},{name:"厦门",code:"xiamen"},{name:"三亚",code:"sanya"},
{name:"上海",code:"shanghai"},{name:"大理",code:"dali"},{name:"泰国",code:"taiguo"},{name:"成都",code:"chengdu"},{name:"拉萨",code:"lasa"},
{name:"杭州",code:"hangzhou"},{name:"香格里拉",code:"xianggelila"},{name:"凤凰",code:"fenghuang"},{name:"西安",code:"xian"},{name:"昆明",code:"kunming"},
{name:"九寨沟",code:"jiuzhaigou"},{name:"哈尔滨",code:"haerbin"},{name:"香港",code:"xianggang"},{name:"桂林",code:"guilin"},{name:"重庆",code:"zhongqing"},
{name:"青岛",code:"qingdao"},{name:"乌镇",code:"wuzhen"},{name:"张家界",code:"zhangjiajie"},{name:"黄山",code:"huangshan"},{name:"西塘",code:"xitang"},
{name:"南京",code:"nanjing"},{name:"澳门",code:"aomen"},{name:"苏州",code:"suzhou"},{name:"深圳",code:"shenzhen"},{name:"西双版纳",code:"xishuangbanna"},
{name:"阳朔",code:"yangshuo"},{name:"广州",code:"guangzhou"},{name:"鼓浪屿",code:"gulangyu"},{name:"台湾",code:"taiwan"},{name:"北海",code:"beihai"},
{name:"大连",code:"dalian"},{name:"普吉岛",code:"pujidao"},{name:"越南",code:"yuenan"},{name:"泸沽湖",code:"luguhu"},{name:"长沙",code:"changsha"},
{name:"武汉",code:"wuhan"},{name:"泰山",code:"taishan"},{name:"韩国",code:"hanguo"},{name:"天津",code:"tianjin"},{name:"凤凰",code:"fenghuanggucheng"},
{name:"曼谷",code:"mangu"},{name:"稻城",code:"daocheng"},{name:"南宁",code:"nanning"},{name:"长白山",code:"changbaishan"},{name:"济南",code:"jinan"},
{name:"舟山",code:"zhoushan"},{name:"尼泊尔",code:"niboer"},{name:"华山",code:"huashan"},{name:"美国",code:"meiguo"},{name:"马来西亚",code:"malaixiya"},
{name:"腾冲",code:"tengchong"},{name:"青海湖",code:"qinghaihu"},{name:"千岛湖",code:"qiandaohu"},{name:"烟台",code:"yantai"},{name:"峨眉山",code:"emeishan"},
{name:"日本",code:"riben"},{name:"漠河",code:"mohe"},{name:"玉龙雪山",code:"yulongxueshan"},{name:"首尔",code:"shouer"},{name:"马尔代夫",code:"maerdaifu"},
{name:"新加坡",code:"xinjiapo"},{name:"敦煌",code:"dunhuang"},{name:"九华山",code:"jiuhuashan"},{name:"柬埔寨",code:"jianpuzhai"},{name:"南昌",code:"nanchang"},
{name:"秦皇岛",code:"qinhuangdao"},{name:"吉林",code:"jilin"},{name:"呼伦贝尔",code:"hulunbeier"},{name:"西湖",code:"xihu"},{name:"黄龙",code:"huanglong"},
{name:"巴厘岛",code:"balidao"},{name:"威海",code:"weihai"},{name:"沈阳",code:"shenyang"},{name:"宏村",code:"hongcun"},{name:"周庄",code:"zhouzhuang"},{name:"普陀山",code:"putuoshan"}]

citys.each do |city|

	$cityname = city[:name];
	$citycode = city[:code];

#	begin

	puts $cityname

		html=open("http://jieban.auyou.cn/"+$citycode.to_s+"/").read

		doc = Nokogiri::HTML.parse html

		thevents = doc.css("#tabcontent1 > div.ly")
		li_in_onepage = thevents.count

		li_in_onepage.times do |lid|

			thevent = thevents[lid]	

			thetitle = thevent.css("div.ly_r > p.lr1").text
			thedate = thevent.css("div.ly_r > p.lr3").text
			thelink = thevent.css("div.ly_r > p.lr1 > a")[0]["href"]


			#出发城市处理
			endposition_startcity = thetitle.index'到'
			start_city = thetitle[3..endposition_startcity-1]

			#目的城市处理
			end_city = $cityname

			
			#出发日期处理
			endposition_startdate = thedate.index'出行'
			start_time_str = thedate[3..endposition_startdate-1]
			start_time = Date.strptime("{ #{start_time_str}}", "{ %Y年%m月%d日 }")


			#回来日期处理
			endposition_enddate = thedate.index'天'
			dateinterval = thedate[endposition_startdate+4..endposition_enddate-1]
			end_time = start_time + dateinterval.to_i

			homepage = "http://jieban.auyou.cn"+thelink
					
			createdate = Time.now				
				
			beautytype = 106			
				
			stmt.execute(homepage.to_s,start_city.to_s,end_city.to_s,start_time.to_s,end_time.to_s,createdate.to_s,beautytype.to_s)

		end
		
	#end while $getPageTimes < $num
	#end while li_in_onepage != 0
end

stmt.close if stmt
dbh.close if dbh
