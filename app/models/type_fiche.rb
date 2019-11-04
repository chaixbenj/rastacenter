class TypeFiche < ApplicationRecord
  belongs_to :domaine
  has_many :fiches
end
