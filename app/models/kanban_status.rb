class KanbanStatus < ApplicationRecord
  belongs_to :domaine
  belongs_to :kanban
end
