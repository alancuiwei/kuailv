class AddA106Ta106ToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :A106, :integer
    add_column :statistics, :TA106, :integer
  end
end
