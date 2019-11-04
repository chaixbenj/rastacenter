class Node < ApplicationRecord
  belongs_to :domaine
  belongs_to :sheet
  has_many :links, :foreign_key => "node_father_id_fk" , :dependent => :destroy
  has_many :links, :foreign_key => "node_son_id_fk" , :dependent => :destroy
  has_many :node_forced_configs, :dependent => :destroy
  has_many :node_forced_computers, :dependent => :destroy
end
