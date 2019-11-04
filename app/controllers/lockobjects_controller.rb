class LockobjectsController < ApplicationController
  before_action :require_login


def delete
  obj_type = params[:obj_type]
	obj_id = params[:obj_id]
  if obj_type != nil and obj_id != nil
    Lockobject.where(:domaine_id => @domaine, :user_id => @my_user_id, :obj_type => obj_type, :obj_id => obj_id).delete_all
  end
  render html: "0"
end



end
