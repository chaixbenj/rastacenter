class Version < ApplicationRecord
  belongs_to :domaine
  has_many :link_obj_versions, :dependent => :destroy
  has_many :project_versions, :dependent => :destroy
  has_many :required_gems, :dependent => :destroy
  has_many :computer_last_gets, :dependent => :destroy
  has_many :data_sets, :dependent => :destroy
  has_many :environnements, :dependent => :destroy
  has_many :appium_caps, :dependent => :destroy
  has_many :actions, :dependent => :destroy
  has_many :sheets, :dependent => :destroy
  has_many :domelements, :dependent => :destroy
  has_many :procedures, :dependent => :destroy
  has_many :tests, :dependent => :destroy
  has_many :runs, :dependent => :destroy
end
