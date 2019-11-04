class Cycle < ApplicationRecord
  belongs_to :domaine
  belongs_to :release
  has_many :campains, :dependent => :destroy
end
