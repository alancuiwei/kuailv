class AddTweibonumTweixinnumTqyernumTautonumToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :tweibonum, :integer
    add_column :statistics, :tweixinnum, :integer
    add_column :statistics, :tqyernum, :integer
    add_column :statistics, :tautonum, :integer
  end
end
