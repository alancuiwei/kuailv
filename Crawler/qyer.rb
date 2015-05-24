#encoding : utf-8
require 'net/http'
require 'json'
require 'nokogiri'
require 'sqlite3'
require 'mysql'

# Database setting, please set pattern db path
$pattern_db = "pattern.dat"

# saved file
$txt = File.open("qyer.log", "w")
$ins = File.open("qyer_insert.sql", "w")

# mysql handle
#$dbh = nil
#$dbh = Mysql.real_connect("localhost", "root", "zhongren#1234", "kuailv-production", 3306);
$dbh = Mysql.real_connect("localhost", "root", "zhongren#1234", "kuailv-production", 3306);

# write insert sql as a file
def gen_insert_file(a1, a2, a3, a4, a5, a6)
  t = get_cur_time
  $ins.puts "INSERT IGNORE INTO activities (f_homepage,start_city,end_city,start_time,end_time,remarks,created_at,beauty) VALUES ('%s','%s','%s','%s','%s','%s','%s',107);" % [a1, a2, a3, a4, a5, a6, t]
end

# insert database directly
def exec_insert_sql(a1, a2, a3, a4, a5, a6)
  t = get_cur_time
  $dbh.query("SET NAMES utf8")
  sql = "INSERT IGNORE INTO activities (f_homepage,start_city,end_city,start_time,end_time,remarks,created_at,beauty) VALUES ('%s','%s','%s','%s','%s','%s','%s',107);" % [a1, a2, a3, a4, a5, a6, t]
  $dbh.query(sql)
end

# pattern map and list
$num_map ={}
$holiday_map ={}
$general_map = {}
$position_list =[]
$contact_map = {}
$date_map = {}
$position_map = {}
$cur_year = nil

def get_num_map
  db=SQLite3::Database.new($pattern_db)
  db.execute("select name,value from tb_num_map;") do |row|
    $num_map[row[0]] = row[1]
  end
  db.close
end

def get_holiday_map
  db=SQLite3::Database.new($pattern_db)
  db.execute("select name,startv,endv from tb_holiday_map;") do |row|
    $holiday_map[row[0]] = [row[1], row[2]]
  end
  db.close
end

def get_general_map
  db=SQLite3::Database.new($pattern_db)
  db.execute("select name,startv,endv from tb_general_day_map;") do |row|
    $general_map[row[0]] = [row[1], row[2]]
  end
  db.close
end

def get_position_list
  db=SQLite3::Database.new($pattern_db)
  db.execute("select name from tb_position_list;") do |row|
    $position_list << row[0]
  end
  db.close
end

def get_contact_map
  db=SQLite3::Database.new($pattern_db)
  db.execute("select id,pattern from tb_contact_pattern;") do |row|
    $contact_map[row[0]] = row[1]
  end
  db.close
end

def get_date_map
  db=SQLite3::Database.new($pattern_db)
  db.execute("select id,pattern from tb_date_pattern;") do |row|
    $date_map[row[0]] = row[1]
  end
  db.close
end

def get_position_map
  db=SQLite3::Database.new($pattern_db)
  db.execute("select id,pattern from tb_position_pattern;") do |row|
    $position_map[row[0]] = row[1]
  end
  db.close
end

def get_cur_year
  today = Time.new
  $cur_year = today.strftime("%Y")
end

def get_cur_time
  today = Time.new
  cur_time = today.strftime('%Y-%m-%d %H:%M:%S').to_s
  return cur_time
end

# filter functions
##################################################################################
# match position by pattern
def position_filter(arg)
  spos = epos = nil
  sflag = eflag = 0
  $position_map.each do |k, v|
    re = Regexp.new(v)
    ####################################
    if ((sflag==0) && (k==1))
      if (arg =~ re)
        mh = $1
        $position_list.each do |p|
          if mh.include? p
            spos = p
            sflag = 1
            arg.gsub!(mh, "")
            break
          end
        end
      end
    end
    ####################################
    if ((eflag==0) && (k==2))
      if (arg =~ re)
        mh = $1
        $position_list.each do |p|
          if mh.include? p
            epos = p
            eflag = 1
            arg.gsub!(mh, "")
            break
          end
        end
      end
    end
  end
  #################################### 
  if (eflag==0)
    $position_list.each do |p|
      if arg.include? p
        epos = p
        eflag = 1
        break
      end
    end
  end
  puts "position_filter>spos #{spos} epos #{epos}"
  return [spos, epos]
end

# match contact by pattern
def contact_filter(arg)
  ph = wx = qq = nil
  $contact_map.each do |k, v|
    re = Regexp.new(v)
    ####################################
    if (k==1)
      if (arg =~ re)
        k0 = $1
        k1 = $2
        k2 = $3
        arg.gsub!(k0, "")
        if (k1 && k1.size > 4)
          ph = k1
          arg.gsub!(k1, "")
        end
        if (k2 && k2.size > 4)
          ph = k2
          arg.gsub!(k2, "")
        end
      end
    end
    ####################################
    if (k==2)
      if (arg =~ re)
        k0 = $1
        k1 = $2
        k2 = $3
        arg.gsub!(k0, "")
        if (k1 && k1.size > 4)
          qq = k1
          arg.gsub!(k1, "")
        end
        if (k2 && k2.size > 4)
          qq = k2
          arg.gsub!(k2, "")
        end
      end
    end
    ####################################
    if (k==3)
      if (arg =~ re)
        k0 = $1
        k1 = $2
        k2 = $3
        arg.gsub!(k0, "")
        if (k1 && k1.size > 4)
          wx = k1
          arg.gsub!(k1, "")
        end
        if (k2 && k2.size > 4)
          wx = k2
          arg.gsub!(k2, "")
        end
      end
    end
    ####################################
  end
  puts "contact_filter>ph #{ph} wx #{wx} qq #{qq}"
  return [ph, wx, qq]
end

# match date by pattern
def date_filter(arg)
  sdate = edate = nil
  sflag = eflag = 0
  sm = sd = em = ey = nil
  sy = ey = $cur_year
  $date_map.each do |k, v|
    re = Regexp.new(v)
    ####################################
    if ((sflag==0) && (eflag==0) &&(k==1))
      if (arg =~ re)
        mh1 = $1
        sdate = $holiday_map[mh1][0].to_s
        edate = $holiday_map[mh1][1].to_s
        sflag = eflag = 1
      end
    end
    ####################################
    if ((sflag==0) && (eflag==0) &&(k==2))
      if (arg =~ re)
        mh1 = $1
        mh2 = $2
        sm = em = $num_map.has_key?(mh1) ? $num_map[mh1] : mh1
        sd = $general_map.has_key?(mh2) ? $general_map[mh2][0] : '01'
        ed = $general_map.has_key?(mh2) ? $general_map[mh2][1] : '01'
        sdate = sy.to_s + "-" + sm + "-" + sd
        edate = ey.to_s + "-" + em + "-" + ed
        sflag = eflag = 1
      end
    end
    ####################################
    if ((sflag==0) && (eflag==0) &&(k==3))
      if (arg =~ re)
        mh1 = $1
        mh2 = $3
        mh3 = $5
        sm = em = $num_map.has_key?(mh1) ? $num_map[mh1] : mh1
        sd = $num_map.has_key?(mh2) ? $day_hash[mh2] : mh2
        ed = $num_map.has_key?(mh3) ? $day_hash[mh3] : mh3
        sdate = sy.to_s + "-" + sm + "-" + sd
        edate = ey.to_s + "-" + em + "-" + ed
        sflag = eflag = 1
      end
    end
    ####################################
    if ((sflag==0) && (eflag==0) &&(k==4))
      if (arg =~ re)
        k1 = $1
        k2 = $3
        k3 = $5
        k4 = $6
        k5 = $7
        k6 = $8
        sm = $num_map.has_key?(k1) ? $num_map[k1] : k1
        sd = $num_map.has_key?(k2) ? $num_map[k2] : k2
        if (k3 =~ /-|~|\u6708|\u53F7/)
          em = $num_map.has_key?(k4) ? $num_map[k4] : k4
          ed = $num_map.has_key?(k6) ? $num_map[k6] : k6
        else
          em = $num_map.has_key?(k3) ? $num_map[k3] : k3
          ed = $num_map.has_key?(k5) ? $num_map[k5] : k5
        end
        sdate = sy.to_s + "-" + sm + "-" + sd
        edate = ey.to_s + "-" + em + "-" + ed
        sflag = eflag = 1
      end
    end
    ####################################
    if ((sflag==0) && (eflag==0) &&(k==5))
      if (arg =~ re)
        k1 = $1
        k2 = $3
        sm = $num_map.has_key?(k1) ? $num_map[k1] : k1
        sd = $num_map.has_key?(k2) ? $num_map[k2] : k2
        sdate = sy.to_s + "-" + sm + "-" + sd
        sflag = 1
      end
    end
    ####################################
  end
  puts "date_filter>sdate #{sdate} edate #{edate}"
  return [sdate, edate]
end

##################################################################################

# init patterns
get_num_map
get_holiday_map
get_general_map
get_position_list
get_position_map
get_contact_map
get_date_map
get_cur_year

# web site setting
#types = Array(67..73)
#type_maps = {67 => '大陆港澳台', 68 => '欧洲', 69 => '美洲', 70 => '非洲', 71 => '亚洲', 72 => '大洋洲', 73 => '无目的地'}
#url1 = 'http://open.qyer.com/qyer/bbs/forum_thread_list?forum_id=2&page='
#url2 = '&forum_type='
#url3 = '&delcache=0&client_id=qyer_android&client_secret=9fcaae8aefc4f9ac4915'

types = Array(1)
url1 = 'http://open.qyer.com/qyer/bbs/forum_thread_list?forum_id=2&page='
url2 = ''
url3 = '&delcache=0&client_id=qyer_android&client_secret=9fcaae8aefc4f9ac4915'

# global variable
thetotal = 0
ccount = 0
sdcount = 0
edcount = 0
spcount = 0
epcount = 0
vcount = 0
vratio = 0
ucount = 0
uratio = 0

# main loop
types.each do |t|
  url = url1 + '0' + url2 + url3
  #url = url1 + '0' + url2 + t.to_s + url3
  #$txt.puts "#{url}"
  resp = Net::HTTP.get_response(URI(url))
  data = resp.body
  result = JSON.parse(data)
  total = result['data']['total']
  page_num = total/10
  $txt.puts "total page number #{page_num}"
  last_thread = nil
  (result['data']['entry']).each do |tid|
    #type = type_maps[t]
    time = Time.at(tid['lastpost']).strftime("%Y-%m-%d %H:%M:%S")
    title = tid['title']
    user = tid['username']
    view = tid['view_url']+'?authorid='+tid['user_id'].to_s
    if (last_thread == tid['view_url'])
      break
    else
      last_thread = tid['view_url']
    end
    content = Net::HTTP.get_response(URI(view))
    doc = Nokogiri::HTML(content.body)
    d1 = doc.css('div.text').text
    d2 = doc.css('td').text
    #$txt.puts view
    contact_arr = [nil, nil]
    date_arr = [nil, nil]
    pos_arr = [nil, nil]
    # filters
    arg1 = title
    arg2 = d1
    arg3 = d2
    arg4 = title + d1 + d2
    raw_data = arg4.gsub(/\s+/, "")
    contact_arr = contact_filter(arg4)
    # different content has different priority
    t1 = date_filter(arg1)
    t2 = date_filter(arg2)
    t3 = date_filter(arg3)
    if (t1[0])
      date_arr[0] = t1[0];
    elsif (t2[0])
      date_arr[0] = t2[0];
    elsif (t3[0])
      date_arr[0] = t3[0];
    end
    if (t1[1])
      date_arr[1] = t1[1];
    elsif (t2[1])
      date_arr[1] = t2[1];
    elsif (t3[1])
      date_arr[1] = t3[1];
    end
    # different content has different priority
    p1 = position_filter(arg1)
    p2 = position_filter(arg2)
    p3 = position_filter(arg3)
    if (p1[0])
      pos_arr[0] = p1[0];
    elsif (p2[0])
      pos_arr[0] = p2[0];
    elsif (p3[0])
      pos_arr[0] = p3[0];
    end
    if (p1[1])
      pos_arr[1] = p1[1];
    elsif (p2[1])
      pos_arr[1] = p2[1];
    elsif (p3[1])
      pos_arr[1] = p3[1];
    end
    if (contact_arr[0] || contact_arr[1] || contact_arr[2])
      ccount +=1
    end
    if (date_arr[0])
      sdcount +=1
    end
    if (date_arr[1])
      edcount +=1
    end
    if (pos_arr[0])
      spcount +=1
    end
    if (pos_arr[1])
      epcount +=1
    end
    if ((contact_arr[0] || contact_arr[1] || contact_arr[2]) && date_arr[0] && pos_arr[0] && pos_arr[1])
      #$txt.puts "记录: 手机:#{contact_arr[0]}微信:#{contact_arr[1]}QQ:#{contact_arr[2]}出发日:#{date_arr[0]}出发地:#{pos_arr[0]}目的地:#{pos_arr[1]}"
      exec_insert_sql(view, pos_arr[0], pos_arr[1], date_arr[0], date_arr[1], title)
      vcount +=1
    end
    if ((contact_arr[0] || contact_arr[1] || contact_arr[2]) && date_arr[0] && pos_arr[1])
#      exec_insert_sql(view, pos_arr[1], date_arr[0], date_arr[1], title)      
      ucount +=1
    end
    thetotal +=1
    vratio = 100 * vcount.to_f/thetotal.to_f
    uratio = 100 * ucount.to_f/thetotal.to_f
    #$txt.puts "总记录数量: #{thetotal}\n有联系方式: #{ccount}\n有出发日期: #{sdcount}\n有回来日期: #{edcount}\n有出发城市: #{spcount}\n有目的城市: #{epcount}"
    $txt.puts "总记录数量: #{thetotal}\n"
    $txt.puts "-------------------------------------------------------------------------------------------------------------------------------"
    $txt.puts "URL: #{view}"
    $txt.puts "解析内容: #{raw_data}"
    spos_v = pos_arr[0] ? pos_arr[0] : "解析失败"
    epos_v = pos_arr[1] ? pos_arr[1] : "解析失败"
    sdate_v = date_arr[0] ? date_arr[0] : "解析失败"
    edate_v = date_arr[1] ? date_arr[1] : "解析失败"
  $txt.puts "联系方式: 手机:#{contact_arr[0]}微信:#{contact_arr[1]}QQ:#{contact_arr[2]}"    
    $txt.puts "出发城市: #{spos_v}"
    $txt.puts "目的城市: #{epos_v}"
    $txt.puts "出发日期: #{sdate_v}"
    $txt.puts "回来日期: #{edate_v}"
#    $txt.puts "-------------------------------------------------------------------------------------------------------------------------------"
    $txt.puts "有效记录数: #{vcount} 记录占比: #{vratio}\%\n"
    $txt.puts "半有效记录: #{ucount} 记录占比: #{uratio}\%\n"
  end

  page_num.times do |i|
    #url = url1 + i.to_s + url2 + t.to_s + url3
    url = url1 + i.to_s + url2 + url3
    #$txt.puts "#{url}"
    resp = Net::HTTP.get_response(URI(url))
    data = resp.body
    result = JSON.parse(data)
    (result['data']['entry']).each do |tid|
      #type = type_maps[t]
      time = Time.at(tid['lastpost']).strftime("%Y-%m-%d %H:%M:%S")
      title = tid['title']
      user = tid['username']
      if (last_thread == tid['view_url'])
        break
      else
        last_thread = tid['view_url']
      end
      view = tid['view_url']+'?authorid='+tid['user_id'].to_s
      content = Net::HTTP.get_response(URI(view))
      doc = Nokogiri::HTML(content.body)
      d1 = doc.css('div.text').text
      d2 = doc.css('td').text
      #$txt.puts "================================================"
      #$txt.puts view
      contact_arr = [nil, nil]
      date_arr = [nil, nil]
      pos_arr = [nil, nil]
      # filters
      arg1 = title
      arg2 = d1
      arg3 = d2
      arg4 = title + d1 + d2
      raw_data = arg4.gsub(/\s+/, "")
      contact_arr = contact_filter(arg4)
      # different content has different priority
      t1 = date_filter(arg1)
      t2 = date_filter(arg2)
      t3 = date_filter(arg3)
      if (t1[0])
        date_arr[0] = t1[0];
      elsif (t2[0])
        date_arr[0] = t2[0];
      elsif (t3[0])
        date_arr[0] = t3[0];
      end
      if (t1[1])
        date_arr[1] = t1[1];
      elsif (t2[1])
        date_arr[1] = t2[1];
      elsif (t3[1])
        date_arr[1] = t3[1];
      end
      # different content has different priority
      p1 = position_filter(arg1)
      p2 = position_filter(arg2)
      p3 = position_filter(arg3)
      if (p1[0])
        pos_arr[0] = p1[0];
      elsif (p2[0])
        pos_arr[0] = p2[0];
      elsif (p3[0])
        pos_arr[0] = p3[0];
      end
      if (p1[1])
        pos_arr[1] = p1[1];
      elsif (p2[1])
        pos_arr[1] = p2[1];
      elsif (p3[1])
        pos_arr[1] = p3[1];
      end
      if (contact_arr[0] || contact_arr[1] || contact_arr[2])
        ccount +=1
      end
      if (date_arr[0])
        sdcount +=1
      end
      if (date_arr[1])
        edcount +=1
      end
      if (pos_arr[0])
        spcount +=1
      end
      if (pos_arr[1])
        epcount +=1
      end
      if ((contact_arr[0] || contact_arr[1] || contact_arr[2]) && date_arr[0] && pos_arr[0] && pos_arr[1])
        vcount +=1
        #$txt.puts "记录: 手机:#{contact_arr[0]}微信:#{contact_arr[1]}QQ:#{contact_arr[2]}出发日:#{date_arr[0]}出发地:#{pos_arr[0]}目的地:#{pos_arr[1]}"
        exec_insert_sql(view, pos_arr[0], pos_arr[1], date_arr[0], date_arr[1], title)
      end
      if ((contact_arr[0] || contact_arr[1] || contact_arr[2]) && date_arr[0] && pos_arr[1])
        ucount +=1
      end
      thetotal +=1
      vratio = 100 * vcount.to_f/thetotal.to_f
      uratio = 100 * ucount.to_f/thetotal.to_f
      #$txt.puts "总记录数量: #{thetotal}\n有联系方式: #{ccount}\n有出发日期: #{sdcount}\n有回来日期: #{edcount}\n有出发城市: #{spcount}\n有目的城市: #{epcount}"
      $txt.puts "总记录数量: #{thetotal}\n"
      $txt.puts "-------------------------------------------------------------------------------------------------------------------------------"
      $txt.puts "URL: #{view}"
      $txt.puts "解析内容: #{raw_data}"
      spos_v = pos_arr[0] ? pos_arr[0] : "解析失败"
      epos_v = pos_arr[1] ? pos_arr[1] : "解析失败"
      sdate_v = date_arr[0] ? date_arr[0] : "解析失败"
      edate_v = date_arr[1] ? date_arr[1] : "解析失败"
    $txt.puts "联系方式: 手机:#{contact_arr[0]}微信:#{contact_arr[1]}QQ:#{contact_arr[2]}"    
      $txt.puts "出发城市: #{spos_v}"
      $txt.puts "目的城市: #{epos_v}"
      $txt.puts "出发日期: #{sdate_v}"
      $txt.puts "回来日期: #{edate_v}"
#      $txt.puts "-------------------------------------------------------------------------------------------------------------------------------"
      $txt.puts "有效记录数: #{vcount} 记录占比: #{vratio}\%\n"
      $txt.puts "半有效记录: #{ucount} 记录占比: #{uratio}\%\n"
    end
    sleep(1.0/100.0)
    #if (thetotal%3000 == 0)
    #  sleep(60)
    #end
  end
end

# close handle
$txt.close if $txt
$ins.close if $ins
$dbh.close if $dbh
