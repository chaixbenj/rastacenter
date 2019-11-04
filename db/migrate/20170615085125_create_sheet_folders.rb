class CreateSheetFolders < ActiveRecord::Migration[5.1]
  def change
    create_table :sheet_folders do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :project_id, :integer, :limit => 8, :null => true
      t.column :sheet_folder_father_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 250, :null => false
      t.column :type_sheet, :string, :limit => 30, :null => true
      t.column :can_be_updated, :integer, :limit => 1, :null => false, :default => 1
      t.timestamps
    end
    
    add_foreign_key :sheet_folders, :domaines
    add_foreign_key :sheet_folders, :projects
    add_foreign_key :sheet_folders, :sheet_folders, column: :sheet_folder_father_id, primary_key: :id
    
    add_index :sheet_folders, [:domaine_id, :project_id, :sheet_folder_father_id], :name => 'idx_sheet_folders_1'
    add_index :sheet_folders, [:domaine_id, :sheet_folder_father_id, :type_sheet], :name => 'idx_sheet_folders_2'
  end
end
