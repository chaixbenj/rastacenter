class Fiche < ApplicationRecord
  belongs_to :domaine
  belongs_to :project
  belongs_to :type_fiche
  has_many :fiche_histos, :dependent => :destroy  
  has_many :fiche_custo_fields, :dependent => :destroy  
  has_many :fiche_links, :dependent => :destroy  
  has_many :fiche_downloads, :dependent => :destroy  
end
