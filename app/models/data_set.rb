class DataSet < ApplicationRecord
  belongs_to :domaine
  has_many :data_set_variables, :dependent => :destroy
end
