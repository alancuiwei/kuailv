class AddFWechatencryptToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :f_wechatencrypt, :string
  end
end
