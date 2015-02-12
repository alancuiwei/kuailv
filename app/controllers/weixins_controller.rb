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

          when "V302"

#              @travelevent = Activity.where(beauty:1).take
              @travelevent = Activity.where(beauty:1).limit(2).order("RAND()").first
              if @travelevent.avatar?nil
                @thepicurl = @travelevent.founder
              else
                @thepicurl = "http://www.lvdazi.com/uploads/activity/avatar/#{@travelevent.id}/thumb_lvdazi.jpg"
              render "rtn302", :formats => :xml    
        end
    end

    if params[:xml][:MsgType]=="text"
        if params[:xml][:Content].include?'/'
          @userinfo = params[:xml][:Content].split("/")
            Activity.new do |newrecord|
              newrecord.start_city = @userinfo[0]
              newrecord.end_city = @userinfo[1]
              newrecord.start_time = Date.strptime("{ 2015-#{@userinfo[2]}}", "{ %Y-%m-%d }")
              newrecord.end_time = Date.strptime("{ 2015-#{@userinfo[3]}}", "{ %Y-%m-%d }")
              newrecord.f_wechatid = @userinfo[4]
              newrecord.f_wechatencrypt = params[:xml][:FromUserName]
              newrecord.save       
            end

            render "rtn120", :formats => :xml

        end        
    end

    if params[:xml][:MsgType]=="image"

            uploadpicurl = params[:xml][:PicUrl]
            @theactivity = Activity.where(f_wechatencrypt:params[:xml][:FromUserName]).last  
            @theactivity.update_attributes(:founder=>uploadpicurl)
                        
            render "rtn130", :formats => :xml

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
