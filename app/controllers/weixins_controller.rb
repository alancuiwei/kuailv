class WeixinsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :check_weixin_legality

  def show
    render :text => params[:echostr]
  end

  def create
#    if params[:xml][:MsgType] == "text"
#      render "echo", :formats => :xml
#    end

    if params[:xml][:Event] == "subscribe"
        render "subscribe", :formats => :xml
    end


    if params[:xml][:Event] == "CLICK"
        case params[:xml][:EventKey]
          when "V110"
              render "rtn110", :formats => :xml
          when "V302"
#              @travelevents = Activity.where(beauty:1).limit(5).order("RAND()")          
              @travelevents = Activity.where(beauty:1).last(10)          
              render "rtn302", :formats => :xml
          when "V303"
              render "rtn303", :formats => :xml
          when "V304"
              render "rtn304", :formats => :xml
          when "V305"
              render "rtn305", :formats => :xml

        end
    end

    if params[:xml][:MsgType]=="text"

        @userinfo = params[:xml][:Content].gsub('，',',').split(',')

        if (@userinfo.count == 4)
            Activity.new do |newrecord|
              newrecord.start_city = @userinfo[0]
              newrecord.end_city = @userinfo[1]
              startmonth = @userinfo[2][0..1]
              startday = @userinfo[2][2..3]
              newrecord.start_time = Date.strptime("{ 2015-#{startmonth}-#{startday}}", "{ %Y-%m-%d }")
              newrecord.qq = @userinfo[3]
              newrecord.f_wechatencrypt = params[:xml][:FromUserName]
              newrecord.beauty = 200
              newrecord.save       
            end
            render "rtn120", :formats => :xml
#        else
#            render "rtn405", :formats => :xml
        end
     
    end

    if params[:xml][:MsgType]=="image"

            noresult = false
            uploadpicurl = params[:xml][:PicUrl]
            @theactivity = Activity.where(f_wechatencrypt:params[:xml][:FromUserName]).last  
            #将 founder字段用来储存 activity活动人的头像。
            @theactivity.update_attributes(:founder=>uploadpicurl)

            target_start_city = @theactivity.start_city
            target_end_city   = @theactivity.end_city
            target_start_time = @theactivity.start_time

            l1_resultevents = Activity.find_by_sql("select * from `kuailv-production`.`activities` where `start_city` LIKE '%#{target_start_city}%' AND `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time-7}' AND '#{target_start_time+7}'  limit 0,1000;")

            l2_resultevents = Activity.find_by_sql("select * from `kuailv-production`.`activities` where `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time-7}' AND '#{target_start_time+7}'  limit 0,1000;")
            
            @resultactivities = l1_resultevents | l2_resultevents

            if (@resultactivities.count > 1)
              
              @theactivity.update_attributes(:result => @resultactivities.count)
#            if (l1_resultevents.count > 1)
#              @resultactivities = l1_resultevents
#              @theactivity.update_attributes(:result=>1)
#            elsif (l2_resultevents.count > 1)
#              @resultactivities = l2_resultevents
#              @theactivity.update_attributes(:result=>2)
            else
              noresult = true  
              @theactivity.update_attributes(:result=>0)
            end
  
            if noresult
              render "rtn404", :format => :xml
            else
 
              if (@resultactivities.count > 10)
                @resultactivities = @resultactivities.first(10)
              end
              render "rtn130", :formats => :xml
            end

    end

  end

  private
  # 根据参数校验请求是否合法，如果非法返回错误页面
  def check_weixin_legality
    array = ["1111qqqq", params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end

  def weixin_params
    params.require(:weixin).permit(:xml)
  end


end
