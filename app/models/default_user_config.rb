class DefaultUserConfig < ApplicationRecord
  belongs_to :domaine
  belongs_to :user
  belongs_to :configuration_variable, :foreign_key => "variable_id"
end
