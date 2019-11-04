class TestStep < ApplicationRecord
  belongs_to :domaine
  belongs_to :test
  has_one :procedure
  has_one :sheet
  has_one :funcandscreen
end
