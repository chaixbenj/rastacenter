class CreateUserNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :user_notifications do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :user_id, :integer, :limit => 8, :null => false
      t.column :sent_by, :string, :limit => 50, :null => true
      t.column :message, :text, :null => true
	  t.column :lu, :integer, :limit => 1, :null => false, :default => 0
	  t.column :sent_by_id, :integer, :limit => 8, :null => true
	  t.column :link_notif_id, :integer, :limit => 8, :null => true
      t.timestamps
    end
    
    add_foreign_key :user_notifications, :domaines
    add_foreign_key :user_notifications, :users
    
    add_index :user_notifications, [:domaine_id, :user_id, :lu], :name => 'idx_user_notifications_1'
	add_index :user_notifications, [:domaine_id, :user_id, :link_notif_id, :id, :lu], :name => 'idx_user_notifications_2'
  end
end
