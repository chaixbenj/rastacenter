class Kanban < ApplicationRecord
  belongs_to :domaine
  has_many :kanban_statuses, :dependent => :destroy  
  has_many :kanban_filters, :dependent => :destroy  
  has_many :kanban_type_fiches, class_name: "KanbanTypeFiche", foreign_key: "kanban_id", :dependent => :destroy  
end
