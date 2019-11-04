class SheetFolder < ApplicationRecord
  belongs_to :domaine
  has_many :sheet_folder, :foreign_key => "sheet_folder_father_id", :dependent => :destroy
  has_many :sheets, :dependent => :destroy
end
