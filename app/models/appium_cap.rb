class AppiumCap < ApplicationRecord
  belongs_to :domaine
  has_many :appium_cap_values, :dependent => :destroy
end
