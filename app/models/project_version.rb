class ProjectVersion < ApplicationRecord
  belongs_to :domaine
  belongs_to :project
  belongs_to :version
end
