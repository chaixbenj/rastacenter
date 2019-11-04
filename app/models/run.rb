class Run < ApplicationRecord
  belongs_to :domaine
  belongs_to :version
  has_one :run_authentication, :dependent => :destroy
  has_many :run_store_data, :dependent => :destroy
  has_many :run_configs, :dependent => :destroy
  has_many :run_suite_schemes, :dependent => :destroy
  has_many :run_step_results, :dependent => :destroy
  has_many :run_screenshots, :dependent => :destroy
  has_many :runs, :foreign_key => "run_father_id", :dependent => :destroy
  has_many :run_ended_nodes, :dependent => :destroy
end
