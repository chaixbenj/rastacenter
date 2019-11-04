class CreateCampains < ActiveRecord::Migration[5.1]
  def change
    create_table :campains do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 250, :null => false
      t.column :description, :text
      t.column :cycle_id, :integer, :limit => 8, :null => false
      t.column :private, :integer, :limit => 1, :default => 0, :null => false
      t.column :owner_user_id, :integer, :limit => 8, :null => true
      t.timestamps
    end
    
    add_foreign_key :campains, :domaines
    add_foreign_key :campains, :cycles
    
    add_index :campains, [:domaine_id, :cycle_id, :owner_user_id, :private], :name => 'idx_campains_1'

  end
end
