class CampainConfig < ApplicationRecord
  belongs_to :domaine
  belongs_to :campain
  belongs_to :configuration_variable, :foreign_key => "variable_id"
end
