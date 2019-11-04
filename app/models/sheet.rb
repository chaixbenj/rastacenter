class Sheet < ApplicationRecord
  belongs_to :domaine
  belongs_to :sheet_folder
  belongs_to :user, :foreign_key => "owner_user_id"
  has_many :nodes, :dependent => :destroy
  has_many :links, :dependent => :destroy
  has_many :campain_test_suites, :dependent => :destroy  
  has_many :runs, :foreign_key => "suite_id", :dependent => :destroy
  has_many :run_step_results, :foreign_key => "suite_id", :dependent => :destroy
end
