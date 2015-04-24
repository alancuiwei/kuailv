#encoding:utf-8
require "uri" 
require "net/http" 
require 'json' 
require 'open-uri'

# 获取token
uri = URI.parse("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wx62143cd77b88851f&secret=5a5c0d8bedc814e66f05e1177d7222a2")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
#http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
array = JSON.parse(response.body)
token = array["access_token"]
puts token

# 设置菜单
params = {"button"=>[

#{"name"=>"找驴友","sub_button"=>[{"type"=>"click","name"=>"找驴友","key"=>"V110"},{"type"=>"click","name"=>"看驴友","key"=>"V302"}]},{"type"=>"click","name"=>"奖红包","key"=>"V305"}]}
{"type"=>"click","name"=>"找人玩","key"=>"V110"},{"type"=>"click","name"=>"南京结伴","key"=>"V305"}]}


http = Net::HTTP.new("api.weixin.qq.com")
request = Net::HTTP::Post.new("/cgi-bin/menu/create?access_token="+token,{'Content-Type' => 'application/json'})
#request.set_form_data(params)
request.body  = params.to_json
response = http.request(request)

puts response
#puts uri
puts params.to_json