class ComputersController < ApplicationController
  before_action :require_login

  
  def index
	@message, @OK = Commun.set_message(flash[:kop])
    @name = params[:sname].to_s
    if @name != ""
      @computers = Computer.where("domaine_id = #{@domaine} and (hostrequest like '%#{@name}%')").order(:hostrequest).all
    else  
      @computers = Computer.where("domaine_id = #{@domaine}").order(:hostrequest).all
    end 
  end  
    
  def delete
    computer_id = params[:computer_id]
    computer = Computer.where(:id => computer_id).first
    if computer != nil
      NodeForcedComputer.where(:domaine_id => @domaine, :hostrequest => computer.hostrequest).delete_all
      ComputerLastGet.where(:domaine_id => @domaine, :hostrequest => computer.hostrequest).delete_all
      computer.destroy
      flash[:kop] = 1
    else
      flash[:kop] = 99
    end
    redirect_to controller: 'computers', action: 'index'
  end  
   

  
end
