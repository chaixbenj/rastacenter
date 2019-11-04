class UserNotification < ApplicationRecord
  belongs_to :domaine
  belongs_to :user
end
