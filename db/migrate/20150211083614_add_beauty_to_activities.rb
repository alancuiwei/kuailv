class AddBeautyToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :beauty, :integer
  end
end
