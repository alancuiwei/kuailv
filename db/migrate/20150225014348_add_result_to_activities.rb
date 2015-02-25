class AddResultToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :result, :integer
  end
end
