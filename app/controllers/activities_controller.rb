class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  def index
# => 所有的数据，昨天的数据，今天至此的记录
    @all_results = Activity.all
    @all_useful_results = Activity.where(start_time: Time.now.midnight..'2015-12-31')

    @all_yesterday_results = Activity.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
    @all_today_results = Activity.where(created_at:Time.now.midnight..Time.now)

    @weibo_yesterday_results = @all_yesterday_results.where(beauty:1)
    @weixin_yesterday_results = @all_yesterday_results.where.not(f_wechatencrypt:"")
    @auto_yesterday_results = @all_yesterday_results.where(beauty: 99..199)
    @auto_100_yesterday_num = @all_yesterday_results.where(beauty:100).count
    @auto_101_yesterday_num = @all_yesterday_results.where(beauty:101).count
    @auto_102_yesterday_num = @all_yesterday_results.where(beauty:102).count
    @auto_103_yesterday_num = @all_yesterday_results.where(beauty:103).count
    @auto_104_yesterday_num = @all_yesterday_results.where(beauty:104).count
    @auto_105_yesterday_num = @all_yesterday_results.where(beauty:105).count

    @weibo_today_results = @all_today_results.where(beauty:1)
    @weixin_today_results = @all_today_results.where.not(f_wechatencrypt:"")
    @auto_today_results = @all_today_results.where(beauty: 99..199)

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
        format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
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
      params.require(:activity).permit(:result,:f_homepage, :avatar,:avatar_cache, :beauty, :f_wechatencrypt, :qq, :mobile, :start_city, :end_city, :start_time, :end_time, :founder, :f_wechatid, :remarks, :f_weiboid)
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
end
