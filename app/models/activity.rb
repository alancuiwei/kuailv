class Activity < ActiveRecord::Base

	mount_uploader :avatar, AvatarUploader
	
#	def self.whenever_add
#		fh = File.new("temp.out", "w")  #创建一个可写文件流
		# 获取页面上所有的链接
#		fh.puts "huoda222" #写入数据
#		fh.close #关闭文件流
#	end 

	  validates_uniqueness_of :qq
	  validates_uniqueness_of :f_wechatid

end
