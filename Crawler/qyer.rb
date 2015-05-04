# encoding : utf-8
require 'nokogiri'
require 'open-uri'
#require "mysql"
require 'faraday'
require 'excon'
class Contact
      def initialize(person,wechat, tel, qq)
        @person=person #
        @wechat=wechat #
        @tel=tel # 
        @qq=qq # 
      end

        def getQQ()
          return @qq
        end

        def getTel()
          return @tel
        end

        def getWechat()
          return @wechat
        end

        def toString()
          txt.puts "qq=#@qq,wechat=#@wechat,tel=#@tel"
        end
end


=begin
dbh = Mysql.real_connect("localhost","root","123456","kuailv-development",3306);
dbh.query("SET NAMES utf8")
sql = "select * from  `citylist` where continent=? and city=?"
stmt=dbh.prepare(sql)
=end


def get_next_of(a)
     return self[self.index(a)+1]
end

def pos_value(pos)
  if(pos==-1)
    return 0
  end
  return pos
end

def getTravel(content)
      city_nums_set=Set.new
      citys_info="地点分析："
      tl1 = TravelLineService.new()
      startCityArr = tl1.parseCity(content, 1);
      targetCityArr = tl1.parseCity(content, 3)
      if(startCityArr.size > 0)
              startCityArr.each do |i|
              if(targetCityArr.size > 0)
                       targetCityArr.each do |j|
                                if (!i.eql? j)
                                  #txt.puts "城市：#{i}-#{j}"
                                  citys_info=citys_info+"城市：#{i}-#{j}"
                                  city_nums_set.add(i)
                                  city_nums_set.add(j)
                                end
                      end
                      else
                        #txt.puts "城市：#{i}-"
                         citys_info=citys_info+ "城市：#{i}-"
                         city_nums_set.add(i)
                      end
              end
              end
              if(targetCityArr.size > 0)
                        targetCityArr.each do |i|
                                  if(startCityArr.size > 0)
                                          startCityArr.each do |j|
                                                    if (!i.eql? j)
                                                            #txt.puts "城市：#{i}-#{j}"
                                                            citys_info=citys_info+ "城市：#{i}-#{j}"
                                                            city_nums_set.add(i)
                                                            city_nums_set.add(j)
                                                    end
                                          end
                                  else
                                   # txt.puts "地点分析：-#{i}"
                                      citys_info=citys_info+ "-#{i}"
                                      city_nums_set.add(i)
                        end
                end
      end

      return city_nums_set.length.to_s+citys_info
end

def getContact(range)
    write_position=range.index("编辑")
    if(write_position!=nil)
        if(range.length>5)
             if(range[0,5]=="本帖最后由")
                range = range[write_position+2,range.length-write_position]
            end
        end     
    end
    if(range!=nil)
      if(range.length>2)
        if(range[0,2]=="回复")
            if(range!=nil&&range.length>2)
              position =range.index(" ")
               if(position!=nil)
                  range=range[position+1,range.length]
                end
            end
           if(range!=nil&&range.length>2)
              position =range.index(" ")
               if(position!=nil)
                range=range[position+1,range.length]
              end
            end
            if(range!=nil&&range.length>2)
              position =range.index("\n")
              if(position!=nil)
                range=range[position+1,range.length]
              end
            end
        end
      end
    end
    wechat=""
    tel=""
    qq=""
    f = File.open("qq.txt","a")
  f.puts "start find:"
  f.puts range
  qqreg2 = /([a-z0-9]*[-_.]?[a-z0-9]+)+@([a-z0-9]*[-_]?[a-z0-9]+)+[\.][a-z]{2,3}([\.][a-z]{2})?$/i
  qqreg1 = /[1-9][0-9]{5,10}/
  #qqreg3-->same with tel
  #6-20个字母数字下划线减号,需要字母开头--->now can all be numbers
  wechatreg=/[a-zA-Z]+[[a-zA-Z0-9]*[-_]?]{5,19}/
  telreg1=/[+]?[86]?[1]+[0-9]{10}/      #电话11位
  telreg2=/[0]+[\d]{2,3}[- ]?[\d]{7,8}/

  #find the number in the range
  #起始位置，正则匹配后，保存下来
  tels = telreg1.match(range)
  if (tels !=nil)  
     tel = tels[0]
     f.puts "tel:"+tel  
  else
    tels = telreg2.match(range);
    if(tels != nil)
          tel = tels[0]
          f.puts "tel:"+tel  
    end
    
  end
  qqs=qqreg1.match(range)
  if (qqs !=nil)
         qq = qqs[0]
          f.puts "qq:"+qq  
  else
    qqs = qqreg2.match(range);
    if(qqs != nil)
         qq = qqs[0]
          f.puts "qq:"+qq  
    end
  end

  wxs=wechatreg.match(range)
  if (wxs !=nil)
    wx = wxs[0]
    # p wx
    if(wx.downcase=="wechat"||wx.downcase=="weixin")
                  wx_pos=range.index(wx)
                  range=range[wx_pos+6,range.length]
                 #  p range
      wxs=wechatreg.match(range)
      if(wxs!=nil)
        wx = wxs[0]
        f.puts "wx:"+wx  
      else
        range=range[0,wx_pos]
        wxs=wechatreg.match(range)
        if(wxs!=nil)
          wx = wxs[0]
          f.puts "wx:"+wx  
        end
      end
      else
              f.puts "wx:"+wx  
          end
  end
  #return Contact.new(person,wechat,qq, tel);
end

#getContact("最近可好 ？我也是西安80后女女 微信：mengbao0320")

#getContact("如五一有兴趣的，可以联系我。Wechat:hewei710")


class KeyWords
  def initialize(keyword, loc, city)
    @keyWords=keyword #关键字
    @locationType=loc #位于目标城市的前面还是后面，1表示前面，2表示后面
    @cityType=city #出发城市还是目的城市，1出发城市，3目的城市
  end

  def getKeyWords()
    return @keyWords
  end

  def getLocation()
    return @locationType
  end

  def getCityType()
    return @cityType
  end

  def toString()
    txt.puts "keyWrods=#@keyWords,locationType=#@locationType,cityType=#@cityType"
  end
end

class TravelLine
  def initialize(startCity, targetCity)
    @startCity=startCity
    @targetCity=targetCity
  end

  def toString()
    txt.puts "startCity=#@startCity,targetCity=#@targetCity"
  end

end
 
class TravelLineService

  def parseCity(remarks, flag)
    txt = File.open("parseCity.txt","w")
    txt.puts(Time.now)
    startKeys = Array.new();
    startKeys[startKeys.size] = KeyWords.new("从", 1, 1);
    startKeys[startKeys.size] = KeyWords.new("坐标", 1, 1)
    startKeys[startKeys.size] = KeyWords.new("在", 1, 1)
    startKeys[startKeys.size] = KeyWords.new("出发", 2, 1)
    startKeys[startKeys.size] = KeyWords.new("-", 2, 1)
    startKeys[startKeys.size] = KeyWords.new("往返", 1, 1)
    startKeys[startKeys.size] = KeyWords.new("往返", 2, 1)
    startKeys[startKeys.size] = KeyWords.new("到", 1, 3)
    startKeys[startKeys.size] = KeyWords.new("到", 2, 1)#add by arilpan
    startKeys[startKeys.size] = KeyWords.new("-", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("目的地", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("去", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("目的地：", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("游", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("游玩", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("游", 2, 3)
    startKeys[startKeys.size]= KeyWords.new("游玩", 2, 3)
    startKeys[startKeys.size]= KeyWords.new("同游", 2, 3)
     
    startKeys[startKeys.size]= KeyWords.new("玩起", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("集合", 1, 1)#2-1:start_city 1-1:before集合 
    startKeys[startKeys.size]= KeyWords.new(" ", 1, 3)
    startKeys[startKeys.size]= KeyWords.new(" ", 2, 3)
    startKeys[startKeys.size]= KeyWords.new("结伴", 2, 3)
    startKeys[startKeys.size]= KeyWords.new("结伴", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("往返", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("往返", 2, 3)
    startKeys[startKeys.size]= KeyWords.new("自由行", 2, 3)
    startKeys[startKeys.size]= KeyWords.new("启程", 1, 3)
    startKeys[startKeys.size]= KeyWords.new("飞", 2, 1)
    startKeys[startKeys.size]= KeyWords.new("飞", 1, 3)
    #txt.puts startKeys.size #自增
    cityArr = Array.new();
    startKeys.each do |i|
      #i.toString()
      key = i.getKeyWords
      loc = i.getLocation
      type = i.getCityType


      startCityLoc = remarks.index(key)

      if (type == flag)
        if (loc==1)
          if (startCityLoc!=nil)
            txt.puts "找到关键字位置在：#{startCityLoc}";
            startCityName = remarks[startCityLoc+key.length, 2]
            txt.puts startCityName;
            holeName = isValidCity(startCityName);
            if (!isExist(cityArr, startCityName) && holeName != nil)
              txt.puts "解析到的城市名称：#{holeName}"
              cityArr[cityArr.size] = holeName
            end
          else
            txt.puts "没有找到关键字"
          end
        else
          if (startCityLoc!=nil)
            txt.puts "找到关键字位置在：#{startCityLoc}";
            startCityName = remarks[startCityLoc-2, 2]
            holeName = isValidCity(startCityName);
            if (!isExist(cityArr, startCityName) && holeName != nil)
              txt.puts "解析到的城市名称：#{holeName}"
              cityArr[cityArr.size] = holeName
            end
          else
            #txt.puts "没有找到关键字"
          end
        end
      end
    end
    return cityArr;
  end


def isExist(cityArr, cityName)
    cityArr.each do |i|
      if (cityName.eql? i)
        return true
      end
    end
    return false
  end

#get all lcitylist & countylist from db,then just check is it in it.
#the contenient(have)--->the nations--->the citys
#这个方法需要改为从数据库中去检索 判断根据关键字检索到的城市名称是否合法
def isValidCity(cityName,continent)
       #sql = "select * from  `citylist` where continent=%#{continent}% and city=%#{cityName}%"
       #puts sql;  
       sql = "select * from  `citylist` where continent=? and city=?"
       stmt=dbh.prepare(sql) 
       stmt.execute(continent,cityName)
       stmt.fetch do |row|
       if(row!=nil )
              if(row[0]!=nil&&row[0]!="")
                    return cityName
              end 
       end
              return nil
       end
end
#最好采用预加载方式，先从数据库中读出来，然后在数组中查询
def isValidCountry(countryName,continent)
      sql = "select * from  `citylist` where continent=? and country=?"
       #puts sql; 
       stmt=dbh.prepare(sql) 
       stmt.execute(continent,countryName)
       stmt.fetch do |row|
       if(row!=nil )
              if(row[0]!=nil&&row[0]!="")
                    return countryName
              end 
       end
              return nil
       end
end

def isValidCity(cityName)
      if(nil == cityName || cityName == "")
            return nil;
      end
       
      #dbh = Mysql.real_connect("localhost","root","123456","kuailv-development",3306);
      #dbh.query("SET NAMES utf8")
      #stmt=dbh.prepare(sql)
      cityArr = Array.new();
      cityArr[cityArr.size] ="乌鲁木齐";
      cityArr[cityArr.size] ="土耳其";
      cityArr[cityArr.size] ="北京";
      cityArr[cityArr.size] ="西藏";
      cityArr[cityArr.size] ="上海";
      cityArr[cityArr.size] ="南京";
      cityArr[cityArr.size] ="广州";
      cityArr[cityArr.size] ="深圳";
      cityArr[cityArr.size] ="香港";
      cityArr[cityArr.size] ="泰国";
      cityArr[cityArr.size] ="杭州";
      cityArr[cityArr.size] ="韩国";
      cityArr[cityArr.size] ="首尔";
      cityArr[cityArr.size] ="欧洲";
      cityArr[cityArr.size] ="香格里拉";
      cityArr[cityArr.size] ="丽江";
      cityArr[cityArr.size] ="尼泊尔";
      cityArr[cityArr.size] ="柬埔寨";
      cityArr[cityArr.size] ="云南";
      cityArr[cityArr.size] ="昆明";
      cityArr[cityArr.size] ="厦门";
      cityArr[cityArr.size] ="日本";
      cityArr[cityArr.size] ="拉萨";
      cityArr[cityArr.size] ="三亚";
      cityArr[cityArr.size] ="成都";
      cityArr[cityArr.size] ="英国";
      cityArr[cityArr.size] ="西藏";
      cityArr[cityArr.size] ="台湾";
      cityArr[cityArr.size] ="丽江";
      cityArr[cityArr.size] ="成都";
      cityArr[cityArr.size] ="林芝";
      cityArr[cityArr.size] ="帕劳";  

      cityArr[cityArr.size] ="稻城亚丁";
      cityArr[cityArr.size] ="武汉";
      cityArr[cityArr.size] ="澳大利亚";
      cityArr[cityArr.size] ="俄罗斯";
      cityArr[cityArr.size] ="冰岛";
      cityArr.each do |i|
        if (i.include? cityName)
          return i
        end
      end
      return nil
    end
end

f= File.new("detail.txt", "w")  #创建一个可写文件流 
txt = File.open("qyer.txt","w")

txt.puts(Time.now)
$getPageTimes = 0;

conn = Faraday.new(:url => "http://bbs.qyer.com") do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.adapter  :excon           # make requests with Net::HTTP
  faraday.options[:timeout] = 200
  faraday.options[:open_timeout] = 200
end

begin
    $getPageTimes +=1;
    response = conn.get "/forum-2-"+$getPageTimes.to_s+".html"     
         #一级页面
    doc = Nokogiri::HTML(response.body)

      thevents = doc.css("#moderate > ul > li")
        
      #txt.puts "1.获得段落：#{thevents}"
      #txt.puts "1.end获得段落"
      li_in_onepage = thevents.count
      txt.puts "list-num:#{li_in_onepage}"
      #li_in_onepage = 1

       li_in_onepage.times do |lid|
      thevent = thevents[lid] 
      thetitle = thevent.css("h3 a").text
      #帖子的链接地址 
      thelink = thevent.css("h3 a")[0]["href"]
              #moderate > ul > li:nth-child(13) > div > p:nth-child(2) > a
              nation = thevent.css("div > p:nth-child(2) > a").text
              p nation
              #无目的地征同游  大陆港澳台征同游  欧洲征同游 美洲征同游 非洲征同游 亚洲征同游 大洋洲征同游  
              nation = nation[0..(nation.index("征同游")-1)]
              #txt.puts "nation:#{nation}"
              #moderate > ul > li:nth-child(9) > div > p.info > span.sum
              post_nums = thevent.css("div > p.info > span.sum").text


              # div > p:nth-child(2) > span > a
              author = thevent.css("div > p > span>a").text
              #find the city according to the nation

              #二级页面---获取多少页:post_nums/15+1
              #thelink:thread-1070639-1.html-->thread-1070639-2.html
              page_nums = post_nums.to_i/15
              txt.puts "author:#{author}"
              
              #txt.puts "page_nums:#{page_nums}"
              #txt.puts "post_nums:#{post_nums}"
              txt.puts   "link ：#{thelink}"
              #arilpan:改成单独页面获取
              post_count=-1
              page_i=1
              first_floor=1
              contact_num=0
              while post_count.to_i < post_nums.to_i do
                  #link ：thread-1063097-1.html
                  #link ：thread-1063097-2.html
                    if(post_count == -1)
                          post_count=1
                    end
                    if(page_i!=1)
                          thelink.delete(".html").delete((page_i-1).to_s)
                          thelink = thelink+page_i.to_s+".html"
                    end
                    son_response = conn.get thelink.to_s
                    #get content author -->analysice

                    sondoc = Nokogiri::HTML(son_response.body)
                    sonevents = sondoc.css("div.bbs_titboxs > div.bbs_titbox > h1").text
                    #author=sondoc.css("#viewthread > div.bbs_titboxs > div > div > div > a.ml10").text
                     if(post_count == 1)
                          txt.puts "title:#{nation}----#{sonevents.to_s}"
                    end
                   
                    #sonevents2= sondoc.css("#viewthread > div.bbs_titboxs > div > h1").text           
                    #txt.puts "1.title2=:#{sonevents2}"
                    #arilpan调用检索程序
                    tl1 = TravelLineService.new()
                    #remarks ="有木有想去土耳其自由行的小伙伴，本人坐标北京，最好是单身女青年，一起结伴游玩、拍照。年龄25+。出游时间4、5月。"
                    #arilpan检索城市
                    startCityArr = tl1.parseCity(sonevents, 1);
                    targetCityArr = tl1.parseCity(sonevents, 3)
                    if(startCityArr.size > 0)
                            startCityArr.each do |i|
                            if(targetCityArr.size > 0)
                                     targetCityArr.each do |j|
                                              if (!i.eql? j)
                                                txt.puts "城市：#{i}-#{j}"
                                              end
                                    end
                                    else
                                      txt.puts "城市：#{i}-"
                                    end
                            end
                            end
                            if(targetCityArr.size > 0)
                                      targetCityArr.each do |i|
                                                if(startCityArr.size > 0)
                                                        startCityArr.each do |j|
                                                                  if (!i.eql? j)
                                                                    txt.puts "城市：#{i}-#{j}"
                                                                  end
                                                        end
                                                else
                                                  txt.puts "地点分析：-#{i}"
                                      end
                              end
                    end

                 
                    list = sondoc.css("#postlist");
                    contents= list.css("div div div:nth-child(2) td")
                    persons= list.css("div div div:nth-child(1) div.userinfo a")
                    f.puts contents.length
                    times=0
                    f.puts persons
                    #arilpan:nil error
                    if persons!=nil
=begin
                            if persons[0]!=nil
                                  author=persons[0].text
                            end
                               author=persons[0].text
=end

                            #先拆分，然后根据楼层和用户名判断是谁说的话，提取联系方式
                           while times< contents.length  do
                                  content = contents[times].text.lstrip.rstrip
                                  person = persons[times].text
                                 
                                  if(author == person)
                                        #city time & wechat
                                        p getTravel(content);
                                  end
                                  getContact(content)
                                  #contact_info=getContact(person,content)
                                  #contact_num=contact_num+contact_info[0,1].to_i
                                 # contact_info=contact_info[1,contact_info.length-1]
                                  f.puts person
                                  f.puts content
                                   if(first_floor==1)
                                                  txt.puts "发帖内容：#{content}"
                                                  first_floor=0
                                                  #txt.puts "联系分析:#{contact_info}"
                                                  content_info=  getTravel(content)
                                                  city_nums = content_info[0,1].to_i
                                                  txt.puts content_info[1,content_info.length-1]

                                  end
                             
                                  times=times+1
                          end
                    end
                    title = sonevents;
                    #各种节假日 年月日正则匹配！！！
                    
                    data_set=Set.new
                    holiday = Array["五一","十一","国庆","元旦","端午","中秋","清明","元宵","春节","重阳","除夕","情人","狂欢","愚人","开斋","圣诞"];
                    regSt  = /(2015[年,\-,\/,\.])?(15[年,\-,\/,\.])?{0,1}(([1-2]{0,1}[0-9])|.)(月|\-|\/|\.)(\d{0,2})(日|号){0,1}/;
                    regEn = /(2015[年,\-,\/,\.])?(15[年,\-,\/,\.])?{0,1}(([1-2]{0,1}[0-9])(月|\-|\/|\.)){0,1}(\d+)(日|号|月){0,1}/;
                    #arilpan  '共13天'  '13天后返回'
                    #匹配第一个
                    startDt = regSt.match(title);
                    if (startDt !=nil)
                         #txt.puts "startDt:"
                         #txt.puts startDt[0];
                         startDtStr = startDt[0];
                         data_set.add(startDtStr)
                         loc = title=~regSt;
                         #txt.puts "loc+startDtStr.length:"
                         #txt.puts loc+startDtStr.length
                          endDtStr = nil;
                          if (nil != startDtStr && startDtStr !="")
                          leftStr = title[loc+startDtStr.length, title.length]
                          #txt.puts "leftStr:"
                          #txt.puts leftStr
                          endDt = leftStr.match(regEn)
                          if (endDt !=nil)
                                endDtStr = endDt[0];
                                   # txt.puts  "endDtStr:#{endDtStr}"
                                    after_data_position=leftStr.index(endDtStr)+endDtStr.length
                                   # txt.puts "leftStr[after_data_position, 1] #{leftStr[after_data_position, 1] }"
                                    if (leftStr[after_data_position, 1] == "天"&&(/[0-9]/.match(leftStr[after_data_position-1, 1]  )!=nil))
                                           endDtStr = endDtStr+"天后" ;
                                           # /abc/.match('cdg') 
                                    end

                           #arilpan如果后面是如28日|号 前面也是5日|号 则判断位月份到达日期;如果后面是天，则加上日期
                           #txt.puts "endDtStr[0,1]:"
                           #txt.puts endDtStr[0, 1];
                           # i can't understand this
                                  if (endDtStr[0, 1] == "-" || endDtStr[0, 1] == "到")
                                        endDtStr = endDtStr[1, endDtStr.length];
                                  end
                                   
                           end
                        end
                      
                    else
                          holiday.each do |i|
                                  if(title.include?i)
                                       #txt.puts "启程:#{i}--返程:";
                                       data_set.add(i)
                                  end
                           end
                    end
                    data_set_string=""
                    data_set.each {|x|  data_set_string=data_set_string+ x }
                   
                    if(post_count ==  1)
                            #txt.puts "日期分析：#{startDtStr}到#{endDtStr}-";
                            txt.puts "日期分析："+data_set_string 
                    end
                    post_count=post_count+15
                    page_i=page_i+1 
            end 
    #sonresponse = conn.get thelink.to_s
              #获取具体回帖页面
              #analisize the contact info
              #verify the start-end time and city
         #sonevents = sondoc.css("#postlist > div.bbs_postview > div.bbs_txtbox > table > tbody > tr > td > p").text
    
              #不同楼层
              #post_10818944
              #postlist
=begin
               postlist=sondoc.css("#postlist")
              postauthors =postlist.css("div > div.userinfo > a").text
              txt.puts "postauthor:#{postauthors}"

              postcontents=postlist.css("table > tbody> tr > td")
              txt.puts "postcontents:#{postcontents}   "
              #article:#postmessage_8985861 > table > tbody > tr > td
              #    #pid10787368 > div.userinfo > a
              #   thelink = thevent.css("h3 a")[0]["href"]
              ##moderate > ul > li:nth-child(13) > div > p:nth-child(2) > a
                  # sonevents = sondoc.css("#postmessage_10737126 > table > tbody > tr > td > p").text
              #txt.puts sonevents
                     # firstReply = "";
              #sonli_in_onepage = sonevents.count
              #txt.puts sonli_in_onepage
=end
              records_num=post_nums.to_i+1
              data_num=data_set.length
              txt.puts "一共分析了#{records_num}个记录，日期成功分析#{data_num}个，地点成功分析#{city_nums}个，联系方式成功分析#{contact_num}个。"
              txt.puts "-----------------------------------------------------------------------------------------------"
      end 
 
#end while li_in_onepage >=3
end while $getPageTimes <3



=begin
txt.close
stmt.close if stmt
dbh.close if dbh
=end