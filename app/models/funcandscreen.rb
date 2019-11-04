class Funcandscreen < ApplicationRecord
  belongs_to :domaine
  belongs_to :project
  has_many :domelements, :dependent => :destroy
  has_many :procedures, :dependent => :destroy
end
