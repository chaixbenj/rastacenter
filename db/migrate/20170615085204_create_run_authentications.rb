class CreateRunAuthentications < ActiveRecord::Migration[5.1]
  def change
    create_table :run_authentications do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :run_id, :integer, :limit => 8, :null => false
      t.column :user_id, :integer, :limit => 8, :null => false
      t.column :uuid, :string, :limit => 40, :null => true
      t.timestamps
    end
    
    add_foreign_key :run_authentications, :domaines
    add_foreign_key :run_authentications, :runs
    add_foreign_key :run_authentications, :users
    
    add_index :run_authentications, [:run_id, :domaine_id], unique: true, :name => 'idx_run_athentications_1'

  end
end
