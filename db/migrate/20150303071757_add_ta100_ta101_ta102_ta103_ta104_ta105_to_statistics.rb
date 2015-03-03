class AddTa100Ta101Ta102Ta103Ta104Ta105ToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :TA100, :integer
    add_column :statistics, :TA101, :integer
    add_column :statistics, :TA102, :integer
    add_column :statistics, :TA103, :integer
    add_column :statistics, :TA104, :integer
    add_column :statistics, :TA105, :integer
  end
end
