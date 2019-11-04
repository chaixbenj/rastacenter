class FuncandscreensController < ApplicationController
  before_action :require_login

  
  def index
	@name =  params[:name]
    @existingFunc, @existingFuncNotLinked = Commun.get_func_and_screens(@selectedversion, @domaine, @my_user_id, @name)
  end  
    

  def delete
	funcsreen = Funcandscreen.where(:id => params[:funcandscreen_id]).first
	if funcsreen != nil then funcsreen.destroy end
	redirect_to :controller => "funcandscreens", :action => "index"
  end
  
end
