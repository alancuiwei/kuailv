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

              @travelevent = Activity.where(beauty:1).limit(2).order("RAND()").first

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
  
            @resultactivity = Activity.limit(2).order("RAND()").first
            if !@resultactivity.founder.nil?
              puts "1111111111111111111"
              @resultpicurl = @resultactivity.founder
            elsif !@resultactivity.avatar.nil?
              puts "2222222222222222222"
              @resultpicurl = "http://www.lvdazi.com/uploads/activity/avatar/#{resultactivity.id}/thumb_lvdazi.jpg"
            else
              puts "3333333333333333333"
              @resultpicurl = "https://mmbiz.qlogo.cn/mmbiz/5NNlNxENLIsAQ686s5sQm0mO0xgMZ2ZUAjJmKLEl4w2pTwOlX0pN4wgIyBuic4Ljx70wrrhpVOu8elukXkfQmAA/0"
            end  

            puts "@@@@@@@@@@@@@@@@@@@"
            puts @resultpicurl

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
