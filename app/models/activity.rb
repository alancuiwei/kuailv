class Activity < ActiveRecord::Base
	def self.whenever_add
		fh = File.new("temp.out", "w")  #创建一个可写文件流
		# 获取页面上所有的链接
		fh.puts "huoda222" #写入数据
		fh.close #关闭文件流
	end 
end
