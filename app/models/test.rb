class Test < ApplicationRecord
  belongs_to :domaine
  belongs_to :test_folder
  belongs_to :user, :foreign_key => "owner_user_id"
  has_many :test_steps, :dependent => :destroy
  has_many :runs, :dependent => :destroy
  has_many :run_step_results, :dependent => :destroy
end
