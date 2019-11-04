class CampainTestSuite < ApplicationRecord
  belongs_to :domaine
  belongs_to :campain
  belongs_to :sheet
  has_many :campain_test_suite_forced_configs, :dependent => :destroy
end
