class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json

  def index
=begin
    l1_successful_matched = 0
    l1_failed_matched = 0

    l2_successful_matched = 0
    l2_failed_matched = 0

    l3_successful_matched = 0
    l3_failed_matched = 0

    activities = Activity.all

    activities.each do |activity|
        target_start_city = activity.start_city
        target_end_city   = activity.end_city
        target_start_time = activity.start_time


        l1_resultcityevents = Activity.where('end_city LIKE ? AND start_city LIKE ?', "%#{target_end_city}%","%#{target_start_city}%")
        l1_resultevents = l1_resultcityevents.where(start_time:((target_start_time-7)..(target_start_time+7)))

        l2_resultcityevents = Activity.where('end_city LIKE ? AND start_city LIKE ?', "%#{target_end_city}%","%#{target_start_city}%")
        l2_resultevents = l2_resultcityevents.where(start_time:((target_start_time-30)..(target_start_time+30)))

        l3_resultcityevents = Activity.where('end_city LIKE ? or start_city LIKE ?', "%#{target_end_city}%","%#{target_start_city}%")
        l3_resultevents = l3_resultcityevents.where(start_time:((target_start_time-7)..(target_start_time+7)))

        if l1_resultevents.count ==1
            l1_failed_matched = l1_failed_matched+1
        else
            l1_successful_matched = l1_successful_matched+1
        end

        if l2_resultevents.count ==1
            l2_failed_matched = l2_failed_matched+1
        else
            l2_successful_matched = l2_successful_matched+1
        end

        if l3_resultevents.count ==1
            l3_failed_matched = l3_failed_matched+1
        else
            l3_successful_matched = l3_successful_matched+1
        end

    end  

    @totalnum = activities.count
    @l1rate = l1_successful_matched*100/@totalnum  
    @l2rate = l2_successful_matched*100/@totalnum  
    @l3rate = l3_successful_matched*100/@totalnum  
=end
  end

  # GET /activities/1
  # GET /activities/1.json
  def show

=begin
      target_start_city = @activity.start_city
      target_end_city   = @activity.end_city
      target_start_time = @activity.start_time
      target_end_time = @activity.end_time

      # SC/DC ==, ^SD < 7days
      resultcityevents = Activity.where('end_city LIKE ? AND start_city LIKE ?', "%#{target_end_city}%","%#{target_start_city}%")
      @resultevents = resultcityevents.where(start_time:((target_start_time-7)..(target_start_time+7)))
=end
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
