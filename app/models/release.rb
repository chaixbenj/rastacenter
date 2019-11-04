class Release < ApplicationRecord
  belongs_to :domaine
  belongs_to :project
  has_many :cycles, :dependent => :destroy
end
