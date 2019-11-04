class RolesController < ApplicationController
  before_action :require_login
  
  def index
    role_id  = (params[:roleid] != nil ? params[:roleid] : flash[:roleid]).to_s
    @rname = params[:rnames].to_s
    @roles = get_role_list(@rname)
    @message, @OK = Commun.set_message(flash[:ko])
    @role = get_role(role_id)
  end

  def getone
    flash[:roleid] = params[:roleid]
    redirect_to controller: 'roles', action: 'index'
  end
    
  def update
    if @can_manage_role == 1
      roleid = params[:roleid].to_s
      if params[:delete] != nil
        ko, role = delete_role(roleid)
      end
      if params[:valid] != nil
        ko, role = update_role(roleid, params[:rname], params[:droits])
      end
    end  
    flash[:ko] = ko
    flash[:roleid] = role
    redirect_to controller: 'roles', action: 'index'
  end
  
  def new
    if @can_manage_role == 1
      if Role.where("name = '#{params[:rnamec]}' and (domaine_id is null or domaine_id = #{@domaine})").first == nil
        role = Role.new
        role.name =  params[:rnamec]
        role.domaine_id = @domaine
        role.droits = "00000000000000000000000000"
        role.save
        role = role.id
      else
        ko = 10
      end
    end
    flash[:ko] = ko
    flash[:roleid] = role
    redirect_to controller: 'roles', action: 'index'
  end  
 

 
  private

  def get_role(rolid)
    role = nil
    if rolid != "" then role = Role.where(:id => rolid).first end
    return role
  end
  
  
  def get_role_list(searchstring)
    roles = nil
    if searchstring != ""
      roles = Role.select("roles.*").where("(domaine_id is null or domaine_id = #{@domaine}) and name like '%#{searchstring}%'").order(:name).all
    else
      roles = Role.select("roles.*").where("domaine_id is null or domaine_id = #{@domaine}").order(:name).all
    end
    return roles
  end
  
  def delete_role(roleid)
    ko, rroleid = nil, nil 
    role = Role.where(:id => roleid).first
    usersurcerole = Userproject.where(:role_id => roleid).first
    if role != nil and usersurcerole == nil and role.domaine_id != nil
      role.destroy
    else
      ko = 4
      rroleid = role.id
    end
    return ko, rroleid
  end
  
  def update_role(roleid, rname, droits)
    ko, rroleid = 1, nil 
    role = Role.where(:id => roleid).first
    if role != nil and role.domaine_id != nil
      if Role.where("name = '#{rname}' and (domaine_id is null or domaine_id = #{@domaine}) and id != #{roleid}").first == nil
        role.name = rname.to_s
        role.droits = droits.to_s
      else
        ko = 10
      end
      role.save
      rroleid = role.id
    end  
    return ko, rroleid
  end
  
  
end
