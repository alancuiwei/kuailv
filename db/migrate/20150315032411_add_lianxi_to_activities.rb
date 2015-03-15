class AddLianxiToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :lianxi, :string
  end
end
