class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :start_city
      t.string :end_city
      t.date :start_time
      t.date :end_time
      t.string :founder
      t.string :f_homepage
      t.string :f_wechatid
      t.text :remarks
      t.string :f_weiboid

      t.timestamps null: false
    end
  end
end
