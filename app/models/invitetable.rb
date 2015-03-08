class Invitetable < ActiveRecord::Base
	validates_uniqueness_of :wechatid
end
