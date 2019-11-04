class ProcedureAction < ApplicationRecord
  belongs_to :domaine
  belongs_to :procedure
  belongs_to :action
end
