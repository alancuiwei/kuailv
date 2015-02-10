class AddFHomepageToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :f_homepage, :string
  end
end
