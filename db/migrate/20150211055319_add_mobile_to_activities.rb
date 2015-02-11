class AddMobileToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :mobile, :string
  end
end
