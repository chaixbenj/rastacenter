class CreateSheets < ActiveRecord::Migration[5.1]
  def change
    create_table :sheets do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :sheet_folder_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 250, :null => false
      t.column :description, :text
      t.column :type_sheet, :string, :limit => 30, :null => true
      t.column :private, :integer, :limit => 1, :null => false, :default => 1
      t.column :owner_user_id, :integer, :limit => 8, :null => false
      t.column :version_id, :integer, :limit => 8, :null => true
      t.column :user_cre, :string, :limit => 50, :null => false
      t.column :user_maj, :string, :limit => 50, :null => true
      t.column :current_id, :integer, :limit => 8
	  t.column :lastresult, :string, :limit => 50, :null => true
      t.timestamps
    end
    
    add_foreign_key :sheets, :domaines
    add_foreign_key :sheets, :sheet_folders
    add_foreign_key :sheets, :versions
    
    add_index :sheets, [:domaine_id, :type_sheet, :version_id, :owner_user_id, :private, :name], name: "idx_sheets_1"
    add_index :sheets, [:domaine_id, :sheet_folder_id, :version_id, :owner_user_id, :private], name: "idx_sheets_2"
    
  end
end
