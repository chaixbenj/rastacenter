class ConfigurationVariable < ApplicationRecord
  belongs_to :domaine
  has_many :default_user_configs, foreign_key: "variable_id", :dependent => :destroy
  has_many :run_configs, foreign_key: "variable_id", :dependent => :destroy
  has_many :node_forced_configs, foreign_key: "variable_id", :dependent => :destroy
  has_many :campain_configs, foreign_key: "variable_id", :dependent => :destroy
  has_many :campain_test_suite_forced_configs, foreign_key: "variable_id", :dependent => :destroy
  has_many :configuration_variable_values, :dependent => :destroy
end
