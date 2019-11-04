class CampainTestSuiteForcedConfig < ApplicationRecord
 belongs_to :domaine
 belongs_to :campain_test_suite  
 belongs_to :configuration_variable, :foreign_key => "variable_id"
end
