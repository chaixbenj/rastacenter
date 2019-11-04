class Liste < ApplicationRecord
  belongs_to :domaine
  has_many :liste_values, :dependent => :destroy
end
