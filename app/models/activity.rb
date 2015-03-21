class Activity < ActiveRecord::Base

	mount_uploader :avatar, AvatarUploader

	validates_presence_of :start_city, :end_city, :start_time, :qq	
#	validates :qq, 
#	:presence => true,
#	:allow_nil => true,
#	:allow_blank => true	

#	validates :f_wechatid, 
#	:uniqueness => true,
#	:allow_nil => true,
#	:allow_blank => true	

end
