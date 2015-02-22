class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

#  $account = 0
  # GET /activities
  # GET /activities.json

  def index
  end

  # GET /activities/1
  # GET /activities/1.json
  def show

#      target_start_city = @activity.start_city
#      target_end_city   = @activity.end_city
#      target_start_time = @activity.start_time
#      target_end_time = @activity.end_time

#      @l1_resultcityevents = Activity.where('end_city LIKE ? AND (start_city LIKE ? OR start_city:"all")', "%#{target_end_city}%","%#{target_start_city}%")
#      @l1_resultevents = @l1_resultcityevents.where(start_time:((target_start_time-7)..(target_start_time+7)))
#      @l1_resultevents = Activity.find_by_sql("select * from `kuailv-development`.`activities` where (`start_city` LIKE '%#{target_start_city}%' OR `start_city` LIKE '%all%') AND `end_city` LIKE '%#{target_end_city}%' AND `start_time` BETWEEN '#{target_start_time-7}' AND '#{target_start_time+7}'  limit 0,1000;")

  end

  # GET /activities/new
  def new

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
      params.require(:activity).permit(:avatar,:avatar_cache, :beauty, :f_wechatencrypt, :qq, :mobile, :start_city, :end_city, :start_time, :end_time, :founder, :f_wechatid, :remarks, :f_weiboid)
    end

end
