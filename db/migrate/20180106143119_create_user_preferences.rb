class CreateUserPreferences < ActiveRecord::Migration[5.1]
  def change
    create_table :user_preferences do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :user_id, :integer, :limit => 8, :null => false
      t.column :jsonpref, :text
      t.timestamps
    end
    
    add_foreign_key :user_preferences, :domaines
    add_foreign_key :user_preferences, :users, column: :user_id, primary_key: :id
    
    add_index :user_preferences, [:domaine_id, :user_id], name: "idx_user_preferences_1"
    

  end
end
