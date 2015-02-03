json.array!(@activities) do |activity|
  json.extract! activity, :id, :start_city, :end_city, :start_time, :end_time, :founder, :f_wechatid, :remarks, :f_weiboid
  json.url activity_url(activity, format: :json)
end
