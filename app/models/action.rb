class Action < ApplicationRecord
  belongs_to :domaine
  has_many :procedure_actions, :dependent => :destroy 
end
