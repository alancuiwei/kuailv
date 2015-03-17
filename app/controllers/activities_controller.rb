class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]
  before_action :authenticate, only: [:nanjing]

  def index
# => 所有的数据，昨天的数据，今天至此的记录
    @all_results = Activity.all

    @all_today_results = Activity.where(created_at:Time.now.midnight..Time.now)


    @weibo_today_results = @all_today_results.where(beauty:1).count
    @weixin_today_results = @all_today_results.where.not(f_wechatencrypt:"").count

    @luntan_today_results = @all_today_results.where(beauty: 799..1000).count

    @auto_today_results = @all_today_results.where(beauty: 99..199).count

    @nanjingevents = @all_results.where("end_city LIKE '%南京%' OR end_city LIKE '%上海%' OR end_city LIKE '%杭州%' OR end_city LIKE '%苏州%' OR end_city LIKE '%无锡%'")
    @nanjingnum = @nanjingevents.count
    @nanjing7num = @nanjingevents.where(start_time:Time.now..Time.now+30.days).count
    @lijiangnum = @all_results.where("end_city LIKE '%丽江%'").count
    @lasanum = @all_results.where("end_city LIKE '%拉萨%'").count
    @sanyanum = @all_results.where("end_city LIKE '%三亚%'").count

    datefilter = (Time.now.midnight - 1.day).strftime("%Y-%m-%d")

    firsttoday = Statistic.where(recorddate:datefilter)

    if firsttoday.empty?

      @datedata = Statistic.new
      @datedata.recorddate = Time.now.midnight - 1.day
      @datedata.totalnum = @all_results.count
      @datedata.tweibonum = @all_results.where(beauty:1).count

      @datedata.tweixinnum = @all_results.where.not(f_wechatencrypt:"").count
      @datedata.tqyernum = @all_results.where(beauty:301).count
      @datedata.tautonum = @all_results.where(beauty: 99..199).count

      @datedata.TA100 = @all_results.where(beauty:100).count
      @datedata.TA101 = @all_results.where(beauty:101).count
      @datedata.TA102 = @all_results.where(beauty:102).count
      @datedata.TA103 = @all_results.where(beauty:103).count
      @datedata.TA104 = @all_results.where(beauty:104).count
      @datedata.TA105 = @all_results.where(beauty:105).count
      @datedata.TA106 = @all_results.where(beauty:106).count

      @datedata.save    

    end

    @reportstatistics = Statistic.all

    @pres801num = @all_results.where(beauty:801).count
    @pres802num = @all_results.where(beauty:802).count
    @pres803num = @all_results.where(beauty:803).count
    @pres804num = @all_results.where(beauty:804).count
    @pres805num = @all_results.where(beauty:805).count
    @pres806num = @all_results.where(beauty:806).count
    @pres807num = @all_results.where(beauty:807).count
    @pres808num = @all_results.where(beauty:808).count
    @pres809num = @all_results.where(beauty:809).count
    @pres810num = @all_results.where(beauty:810).count
    @pres811num = @all_results.where(beauty:811).count
    @pres812num = @all_results.where(beauty:812).count
    @pres818num = @all_results.where(beauty:818).count
    @pres817num = @all_results.where(beauty:817).count
    @pres819num = @all_results.where(beauty:819).count
    @pres900num = @all_results.where(beauty:900).count

    @selected818 = Invitetable.all.where(inviteid: "R818" || "r818")

    @s818wechatnum = 0

    @selected818.each do |s818|
      if (!@all_results.where(f_wechatencrypt: s818.wechatid).empty?)
        @s818wechatnum +=1
      end
    end

    @selected900 = Invitetable.all.where(inviteid: "R900" || "r900")
    @s900wechatnum = 0
    @selected900.each do |s900|
      if (!@all_results.where(f_wechatencrypt: s900.wechatid).empty?)
        @s900wechatnum +=1
      end
    end

    @selected801 = Invitetable.all.where(inviteid: "R801" || "r801")
    @s801wechatnum = 0
    @selected801.each do |s801|
      if (!@all_results.where(f_wechatencrypt: s801.wechatid).empty?)
        @s801wechatnum +=1
      end
    end

    @selected802 = Invitetable.all.where(inviteid: "R802" || "r802")
    @s802wechatnum = 0
    @selected802.each do |s802|
      if (!@all_results.where(f_wechatencrypt: s802.wechatid).empty?)
        @s802wechatnum +=1
      end
    end

    @selected803 = Invitetable.all.where(inviteid: "R803" || "r803")
    @s803wechatnum = 0
    @selected803.each do |s803|
      if (!@all_results.where(f_wechatencrypt: s803.wechatid).empty?)
        @s803wechatnum +=1
      end
    end

    @selected804 = Invitetable.all.where(inviteid: "R804" || "r804")
    @s804wechatnum = 0
    @selected804.each do |s804|
      if (!@all_results.where(f_wechatencrypt: s804.wechatid).empty?)
        @s804wechatnum +=1
      end
    end

    @selected805 = Invitetable.all.where(inviteid: "R805" || "r805")
    @s805wechatnum = 0
    @selected805.each do |s805|
      if (!@all_results.where(f_wechatencrypt: s805.wechatid).empty?)
        @s805wechatnum +=1
      end
    end

    @selected806 = Invitetable.all.where(inviteid: "R806" || "r806")
    @s806wechatnum = 0
    @selected806.each do |s806|
      if (!@all_results.where(f_wechatencrypt: s806.wechatid).empty?)
        @s806wechatnum +=1
      end
    end

    @selected807 = Invitetable.all.where(inviteid: "R807" || "r807")
    @s807wechatnum = 0
    @selected807.each do |s807|
      if (!@all_results.where(f_wechatencrypt: s807.wechatid).empty?)
        @s807wechatnum +=1
      end
    end

    @selected808 = Invitetable.all.where(inviteid: "R808" || "r808")
    @s808wechatnum = 0
    @selected808.each do |s808|
      if (!@all_results.where(f_wechatencrypt: s808.wechatid).empty?)
        @s808wechatnum +=1
      end
    end

    @selected809 = Invitetable.all.where(inviteid: "R809" || "r809")
    @s809wechatnum = 0
    @selected809.each do |s809|
      if (!@all_results.where(f_wechatencrypt: s809.wechatid).empty?)
        @s809wechatnum +=1
      end
    end

    @selected810 = Invitetable.all.where(inviteid: "R810" || "r810")
    @s810wechatnum = 0
    @selected810.each do |s810|
      if (!@all_results.where(f_wechatencrypt: s810.wechatid).empty?)
        @s810wechatnum +=1
      end
    end

    @selected811 = Invitetable.all.where(inviteid: "R811" || "r811")
    @s811wechatnum = 0
    @selected811.each do |s811|
      if (!@all_results.where(f_wechatencrypt: s811.wechatid).empty?)
        @s811wechatnum +=1
      end
    end

    @selected812 = Invitetable.all.where(inviteid: "R812" || "r812")
    @s812wechatnum = 0
    @selected812.each do |s812|
      if (!@all_results.where(f_wechatencrypt: s812.wechatid).empty?)
        @s812wechatnum +=1
      end
    end

    @selected817 = Invitetable.all.where(inviteid: "R817" || "r817")
    @s817wechatnum = 0
    @selected817.each do |s817|
      if (!@all_results.where(f_wechatencrypt: s817.wechatid).empty?)
        @s817wechatnum +=1
      end
    end

    @selected819 = Invitetable.all.where(inviteid: "R819" || "r819")
    @s819wechatnum = 0
    @selected819.each do |s819|
      if (!@all_results.where(f_wechatencrypt: s819.wechatid).empty?)
        @s819wechatnum +=1
      end
    end


  end

  def show

    target_start_city = @activity.start_city
    target_end_city   = @activity.end_city
    target_start_time = @activity.start_time

    l1_resultevents = Activity.find_by_sql("select * from `kuailv-production`.`activities` where `start_city` LIKE '%#{target_start_city}%' AND `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time-7}' AND '#{target_start_time+7}'  limit 0,1000;")

    l2_resultevents = Activity.find_by_sql("select * from `kuailv-production`.`activities` where `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time-7}' AND '#{target_start_time+7}'  limit 0,1000;")

    @l1_match_number = l1_resultevents.count - 1
    @l2_match_number = l2_resultevents.count

  end

  # GET /activities/new
  def new
    @activity = Activity.new
  end

  def qyer
    @activity = Activity.new
  end

  def nanjing

    @all_results = Activity.all

#    @nanjings = @all_results.where("end_city LIKE '%南京%' OR end_city LIKE '%上海%' OR end_city LIKE '%杭州%' OR end_city LIKE '%苏州%' OR end_city LIKE '%无锡%'")
    @nanjings = @all_results.where("end_city LIKE '%南京%'")
    @nanjings30 = @nanjings.where(start_time:"2015-03-01"..Time.now+7.days)

  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(activity_params)

    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: 'Activity was successfully created.' }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
#        format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
        format.html { redirect_to "/activities/nanjing", notice: 'Activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_url, notice: 'Activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params.require(:activity).permit(:lianxi, :result,:f_homepage, :avatar,:avatar_cache, :beauty, :f_wechatencrypt, :qq, :mobile, :start_city, :end_city, :start_time, :end_time, :founder, :f_wechatid, :remarks, :f_weiboid)
    end

    def authenticate
     authenticate_or_request_with_http_basic do |username, password|
       username == "ziren" && password == "Faith#7915"
     end
    end    

#   1: weibo input

# => automatic input

#   100: ctrip input
#   101: doyouhike input
#   102: yueban.com input
#   103: luguai input    
#   104: pintour input    
#   105: mafengwo input    

#   200: userself weixin input

# => employee manual input

#   301: qyer manual input
#   800 - 820: shaoli manual input
end
