class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.date :recorddate
      t.integer :totalnum
      t.integer :deltanum
      t.integer :weibonum
      t.integer :weixinnum
      t.integer :qyernum
      t.integer :autonum
      t.integer :A100
      t.integer :A101
      t.integer :A102
      t.integer :A103
      t.integer :A104
      t.integer :A105

      t.timestamps null: false
    end
  end
end
