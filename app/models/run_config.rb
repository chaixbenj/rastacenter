class RunConfig < ApplicationRecord
 belongs_to :domaine
 belongs_to :run  
 belongs_to :configuration_variable, :foreign_key => "variable_id"
end
