class KanbanTypeFiche < ApplicationRecord
  belongs_to :domaine
  belongs_to :kanban
  belongs_to :type_fiche
end
