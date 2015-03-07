class Activity < ActiveRecord::Base

	mount_uploader :avatar, AvatarUploader
	
	validates :qq, 
	:uniqueness => true
	:allow_nil => true,
	:allow_blank => true	

	validates :f_wechatid, 
	:uniqueness => true
	:allow_nil => true,
	:allow_blank => true	
end
