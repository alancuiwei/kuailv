class CreateInvitetables < ActiveRecord::Migration
  def change
    create_table :invitetables do |t|
      t.string :inviteid
      t.string :wechatid

      t.timestamps null: false
    end
  end
end
