class Procedure < ApplicationRecord
  belongs_to :domaine
  belongs_to :funcandscreen
  has_many :procedure_actions, :dependent => :destroy 
  has_many :test_steps, :dependent => :destroy
end
