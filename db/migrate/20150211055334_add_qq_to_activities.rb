class AddQqToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :qq, :string
  end
end
