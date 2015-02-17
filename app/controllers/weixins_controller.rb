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


    if params[:xml][:Event] == "CLICK"
        case params[:xml][:EventKey]
          when "V110"

              render "rtn110", :formats => :xml

#          when "V302"

#              @travelevent = Activity.where(beauty:1).limit(2).order("RAND()").first

#              render "rtn302", :formats => :xml    

        end
    end

    if params[:xml][:MsgType]=="text"
        if params[:xml][:Content].include?','
          @userinfo = params[:xml][:Content].split(",")
        else
          @userinfo = params[:xml][:Content].split("，")
        end

            Activity.new do |newrecord|
              newrecord.start_city = @userinfo[0]
              newrecord.end_city = @userinfo[1]
              startmonth = @userinfo[2][0..1]
              startday = @userinfo[2][2..3]
              newrecord.start_time = Date.strptime("{ 2015-#{startmonth}-#{startday}}", "{ %Y-%m-%d }")
              newrecord.qq = @userinfo[3]
              newrecord.f_wechatencrypt = params[:xml][:FromUserName]
              newrecord.save       
            end

            render "rtn120", :formats => :xml

     
    end

    if params[:xml][:MsgType]=="image"

            noresult = false
            uploadpicurl = params[:xml][:PicUrl]
            @theactivity = Activity.where(f_wechatencrypt:params[:xml][:FromUserName]).last  
            @theactivity.update_attributes(:founder=>uploadpicurl)

            target_start_city = @theactivity.start_city
            target_end_city   = @theactivity.end_city
            target_start_time = @theactivity.start_time
#            target_start_time = @theactivity.start_time

#            l1_resultcityevents = Activity.where('end_city LIKE ? AND (start_city LIKE ? OR start_city:"all")', "%#{target_end_city}%","%#{target_start_city}%")
#            l1_resultevents = l1_resultcityevents.where(start_time:((target_start_time-7)..(target_start_time+7)))

            l1_resultevents = Activity.find_by_sql("select * from `kuailv-production`.`activities` where (`start_city` LIKE '%#{target_start_city}%' OR `start_city` LIKE '%all%') AND `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time-7}' AND '#{target_start_time+7}'  limit 0,1000;")

            if l1_resultevents.count == 1
                  noresult = true
            else
              @resultactivities = l1_resultevents
            end
  
#            @resultactivity = Activity.limit(2).order("RAND()").first
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
