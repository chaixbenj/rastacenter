class Environnement < ApplicationRecord
  belongs_to :domaine
  has_many :environnement_variables, :dependent => :destroy
end
