class NodeForcedConfig < ApplicationRecord
  belongs_to :domaine
  belongs_to :node
  belongs_to :configuration_variable, :foreign_key => "variable_id"
end
