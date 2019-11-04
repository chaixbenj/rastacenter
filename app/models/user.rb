class User < ApplicationRecord
    belongs_to :domaine
    has_one :user_preference, :dependent => :destroy
    has_many :userprojects, :dependent => :destroy
	has_many :user_notifications, :dependent => :destroy
    has_many :default_user_configs, :dependent => :destroy
    has_many :run_authentications, :dependent => :destroy
	has_many :lockobjects, :dependent => :destroy
    has_many :sheets, :foreign_key => "owner_user_id"
    has_many :tests, :foreign_key => "owner_user_id"
    has_many :campains, :foreign_key => "owner_user_id"
end
