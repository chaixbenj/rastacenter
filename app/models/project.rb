class Project < ApplicationRecord
  belongs_to :domaine
  has_many :fiches
  has_many :userprojects, :dependent => :destroy  
  has_many :releases, :dependent => :destroy
  has_many :test_folders, :dependent => :destroy
  has_many :sheet_folders, :dependent => :destroy
  has_many :funcandscreens, :dependent => :destroy
  has_many :environnement_variables, :dependent => :destroy
  has_many :data_set_variables, :dependent => :destroy
  has_many :test_constantes, :dependent => :destroy
  has_many :project_versions, :dependent => :destroy
 end
