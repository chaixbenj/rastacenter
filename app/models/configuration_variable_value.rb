class ConfigurationVariableValue < ApplicationRecord
  belongs_to :domaine
  belongs_to :configuration_variable
 end
