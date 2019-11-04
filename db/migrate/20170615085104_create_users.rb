#done
class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => true
      t.column :login, :string, :limit => 50, :null => false
      t.column :pwd, :string, :limit => 50, :null => false
      t.column :username, :string, :limit => 50, :null => false
      t.column :idnavigation, :string, :limit => 40, :null => true
      t.column :project_id, :integer, :limit => 8, :null => true
      t.column :is_admin, :integer, :default => 0, :limit => 1, :null => false
      t.column :dateidnavigation , :datetime
	  t.column :preferences, :string, :limit => 255, :null => true
	  t.column :email, :string, :limit => 254, :null => true
	  t.column :locked, :integer, :limit => 1, :null => true
      t.timestamps
    end

    add_foreign_key :users, :domaines
    add_foreign_key :users, :projects
    add_index :users, [:domaine_id, :username, :login], :name => 'idx_users_1'
    add_index :users, [:login],  unique: true, name: "idx_users_2"
   #password = superadmin	
   User.create id: 0,
                login: 'superadmin',
                pwd: 's6cDoxnMvulNvwHve1lMsG3luGmf3NJLrs01u6VJbCQ=',
                username: 'superadmin',
                is_admin: 1,
                domaine_id: 0
  end
end
