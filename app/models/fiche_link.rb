class FicheLink < ApplicationRecord
  belongs_to :domaine
  belongs_to :fiche
end
