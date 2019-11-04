class Role < ApplicationRecord
  belongs_to :domaine
  has_many :userprojects, :dependent => :destroy
end
