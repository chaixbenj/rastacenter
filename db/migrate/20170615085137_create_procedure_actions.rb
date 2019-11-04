class CreateProcedureActions < ActiveRecord::Migration[5.1]
  def change
    create_table :procedure_actions do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :procedure_id, :integer, :limit => 8, :null => false
      t.column :action_id, :integer, :limit => 8, :null => false
      t.timestamps
    end
    
    add_foreign_key :procedure_actions, :domaines
    add_foreign_key :procedure_actions, :procedures
    add_foreign_key :procedure_actions, :actions
    
    add_index :procedure_actions, [:domaine_id, :action_id] , :name => 'idx_procedure_actions_1'
    add_index :procedure_actions, [:domaine_id, :procedure_id] , :name => 'idx_procedure_actions_2'
  end
end
