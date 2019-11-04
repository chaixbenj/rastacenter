class Campain < ApplicationRecord
  belongs_to :domaine
  belongs_to :cycle
  belongs_to :user, :foreign_key => "owner_user_id"
  has_many :campain_configs, :dependent => :destroy
  has_many :campain_test_suites, :dependent => :destroy
  has_many :runs, :dependent => :destroy
end
