class TestFolder < ApplicationRecord
  belongs_to :domaine
  has_many :test_folder, :foreign_key => "test_folder_father_id", :dependent => :destroy
  has_many :tests, :dependent => :destroy
end
