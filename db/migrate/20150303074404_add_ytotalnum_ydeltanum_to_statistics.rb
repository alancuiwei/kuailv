class AddYtotalnumYdeltanumToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :ytotalnum, :integer
    add_column :statistics, :ydeltanum, :integer
  end
end
