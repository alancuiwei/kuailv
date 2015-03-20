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

#    @pres800num = @all_results.where(beauty:801..820).count

#    @pres900num = @all_results.where(beauty:900).count

#    @selected800 = Invitetable.all.where(inviteid: "R802" || "r802" ||"R803" || "r803" ||"R817" || "r817" ||"R819" || "r819")

#    @selected900 = Invitetable.all.where(inviteid: "R900" || "r900")

#    @s900wechatnum = 0
#    @selected900.each do |s900|
#      if (!@all_results.where(f_wechatencrypt: s900.wechatid).empty?)
#        @s900wechatnum +=1
#      end
#    end

  end

  def show

    target_start_city = @activity.start_city
    target_end_city   = @activity.end_city
    target_start_time = @activity.start_time

    @l1_resultevents = Activity.find_by_sql("select * from `kuailv-production`.`activities` where `start_city` LIKE '%#{target_start_city}%' AND `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time-7}' AND '#{target_start_time+7}'  limit 0,1000;")

    @l2_resultevents = Activity.find_by_sql("select * from `kuailv-production`.`activities` where `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time-7}' AND '#{target_start_time+7}'  limit 0,1000;")

    @l1_match_number = @l1_resultevents.count
    @l2_match_number = @l2_resultevents.count

  end

  # GET /activities/new
  def new
    @activity = Activity.new
  end

  def qyer
    @activity = Activity.new
  end

  def nanjing

    @all_results = Activity.all.order(start_time: :desc)

#    @nanjings = @all_results.where("end_city LIKE '%南京%' OR end_city LIKE '%上海%' OR end_city LIKE '%杭州%' OR end_city LIKE '%苏州%' OR end_city LIKE '%无锡%'")
    @nanjings = @all_results.where("end_city LIKE '%南京%'")
    @nanjings30 = @nanjings.where(start_time:"2015-03-01"..Time.now+30.days).where(beauty: 99..199)

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
