class RequiredGemsController < ApplicationController
  before_action :require_login

  
  def index
    @popup = params[:popup].to_s
    if params[:kop].to_s == '0'
      @message = I18n.t "message.une_erreur_est_survenue"
      @OK = true
    end
    if params[:kop].to_s == '1'
      @message = I18n.t "message.maj_effectuee"
      @OK = true
    end
    @message, @OK = Commun.set_message(params[:kop])
	
    required_gem = RequiredGem.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
    if   required_gem != nil
      @gems = required_gem.gems.gsub("require ", "").gsub("'","")
    else
      @gems = ""
    end

  end  

  def update
    gems = params[:gems].to_s
    popup = params[:popup].to_s 
    tgems = gems.to_s.split("\n")
    for i in 0..tgems.length-1
      if tgems[i] != nil  and tgems[i].strip != nil and tgems[i].strip != ""
        tgems[i] = "require '#{tgems[i].strip}'"
      end
    end
    gems = tgems.join("\n")
    required_gem = RequiredGem.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
    if required_gem == nil
      required_gem = RequiredGem.new
      required_gem.domaine_id = @domaine
      required_gem.version_id = @selectedversion
	  required_gem.save
	  required_gem.current_id = required_gem.id
    end
    required_gem.gems = gems
    required_gem.save
    kop = 1
    redirect_to controller: 'required_gems', action: 'index', kop: kop, popup: popup
  end
  
end
